require 'rubygems'
require 'config.rb'

require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'

task :default => [:test]

PKG_FILE_NAME      = "#{CONFIG[:name]}-#{CONFIG[:version]}"
RUBY_FORGE_PROJECT = 'valuable'
RUBY_FORGE_USER    = 'mustmodify'

desc "Run unit tests"
Rake::TestTask.new("test") { |t|
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = true
}

desc 'clean temporary files, rdoc, and gem package'
task :clean => [:clobber_package, :clobber_rdoc] do
  temp_filenames = File.join('**', '*.*~')
  temp_files = Dir.glob(temp_filenames)
  if temp_files.empty? 
      puts 'no temp files to delete' 
  else
      puts "deleting #{temp_files.size} temp files"
  end
  
  File.delete(*temp_files) 
end

desc 'Generate documentation for the Valuable plugin'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.title   = 'Valuable - light weight modeling'
  rdoc.options << '--line-numbers'
  rdoc.options << '--inline-source'
  rdoc.rdoc_files.include('README.txt')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

spec = Gem::Specification.new do |s| 
  s.name = CONFIG[:name]
  s.version = CONFIG[:version]
  s.platform = Gem::Platform::RUBY
  s.summary = 'attr_accessor on steroids with defaults, constructor, and light casting.'
  s.description = "Valuable is a ruby base class that is essentially attr_accessor on steroids. Its aim is to provide Rails-like goodness where ActiveRecord isn't an option. It intends to use a simple and intuitive interface, allowing you to get on with the logic specific to your application."

  s.files = FileList["{lib, test}/**/*"].to_a + %w( README.txt rakefile.rb )
  s.add_dependency 'activesupport'
  s.add_dependency 'ruby-decimal'
  s.require_path = 'lib'
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = false

  s.rubyforge_project = RUBY_FORGE_PROJECT
  s.author = 'Johnathon Wright'
  s.email = 'jw@mustmodify.com'
  s.homepage = 'http://valuable.mustmodify.com'
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  #pkg.need_zip = true
  #pkg.need_tar = true 
end 

desc "Publish the API documentation"
task :pdoc => [:rdoc] do
  Rake::RubyForgePublisher.new(RUBY_FORGE_PROJECT, RUBY_FORGE_USER).upload
end

desc 'Publish the gem and API docs'
task :publish => [:pdoc, :rubyforge_upload]

desc "Publish the release files to RubyForge."
task :rubyforge_upload => :package do
  files = %w(gem tgz).map { |ext| "pkg/#{CONFIG[:name]}.#{ext}" }

  if RUBY_FORGE_PROJECT then
    require 'net/http'
    require 'open-uri'

    project_uri = "http://rubyforge.org/projects/#{RUBY_FORGE_PROJECT}/"
    project_data = open(project_uri) { |data| data.read }
    group_id = project_data[/[?&]group_id=(\d+)/, 1]
    raise "Couldn't get group id" unless group_id

    # This echos password to shell which is a bit sucky
    if ENV["RUBY_FORGE_PASSWORD"]
      password = ENV["RUBY_FORGE_PASSWORD"]
    else
      print "#{RUBY_FORGE_USER}@rubyforge.org's password: "
      password = STDIN.gets.chomp
    end

    login_response = Net::HTTP.start("rubyforge.org", 80) do |http|
      data = [
        "login=1",
        "form_loginname=#{RUBY_FORGE_USER}",
        "form_pw=#{password}"
      ].join("&")
      http.post("/account/login.php", data)
    end

    cookie = login_response["set-cookie"]
    raise "Login failed" unless cookie
    headers = { "Cookie" => cookie }

    release_uri = "http://rubyforge.org/frs/admin/?group_id=#{group_id}"
    release_data = open(release_uri, headers) { |data| data.read }
    package_id = release_data[/[?&]package_id=(\d+)/, 1]
    raise "Couldn't get package id" unless package_id

    first_file = true
    release_id = ""

    files.each do |filename|
      basename  = File.basename(filename)
      file_ext  = File.extname(filename)
      file_data = File.open(filename, "rb") { |file| file.read }

      puts "Releasing #{basename}..."

      release_response = Net::HTTP.start("rubyforge.org", 80) do |http|
        release_date = Time.now.strftime("%Y-%m-%d %H:%M")
        type_map = {
          ".zip"    => "3000",
          ".tgz"    => "3110",
          ".gz"     => "3110",
          ".gem"    => "1400"
        }; type_map.default = "9999"
        type = type_map[file_ext]
        boundary = "rubyqMY6QN9bp6e4kS21H4y0zxcvoor"

        query_hash = if first_file then
          {
            "group_id" => group_id,
            "package_id" => package_id,
            "release_name" => PKG_FILE_NAME,
            "release_date" => release_date,
            "type_id" => type,
            "processor_id" => "8000", # Any
            "release_notes" => "",
            "release_changes" => "",
            "preformatted" => "1",
            "submit" => "1"
          }
        else
          {
            "group_id" => group_id,
            "release_id" => release_id,
            "package_id" => package_id,
            "step2" => "1",
            "type_id" => type,
            "processor_id" => "8000", # Any
            "submit" => "Add This File"
          }
        end

        query = "?" + query_hash.map do |(name, value)|
          [name, URI.encode(value)].join("=")
        end.join("&")

        data = [
          "--" + boundary,
          "Content-Disposition: form-data; name=\"userfile\"; filename=\"#{basename}\"",
          "Content-Type: application/octet-stream",
          "Content-Transfer-Encoding: binary",
          "", file_data, ""
          ].join("\x0D\x0A")

        release_headers = headers.merge(
          "Content-Type" => "multipart/form-data; boundary=#{boundary}"
        )

        target = first_file ? "/frs/admin/qrs.php" : "/frs/admin/editrelease.php"
        http.post(target + query, data, release_headers)
      end

      if first_file then
        release_id = release_response.body[/release_id=(\d+)/, 1]
        raise("Couldn't get release id") unless release_id
      end

      first_file = false
    end
  end
end

