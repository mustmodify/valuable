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
  rdoc.rdoc_files.include('README.markdown')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

spec = Gem::Specification.new do |s| 
  s.name = CONFIG[:name]
  s.version = CONFIG[:version]
  s.platform = Gem::Platform::RUBY
  s.summary = 'attr_accessor on steroids with defaults, constructor, and light casting.'
  s.description = "Valuable is a ruby base class that is essentially attr_accessor on steroids. It intends to use a simple and intuitive interface, allowing you to get on with the logic specific to your application."

  s.files = FileList["{lib, test, examples}/**/*"].to_a + %w( README.markdown rakefile.rb )
  s.require_path = 'lib'
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true

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

