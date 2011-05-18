#!/usr/bin/env rake

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/testtask'

desc "Run unit tests"
Rake::TestTask.new("test") { |t|
  t.libs << 'test'
  t.pattern = 'test/*.rb'
  t.verbose = true
  t.warning = true
}


desc 'Generate HTML readme file'
task :readme do
  `markdown README.markdown > README.html`
end

desc 'clean temporary files, rdoc, and gem package'
task :clean => [:clobber_package, :clobber_rdoc] do
  temp_filenames = File.join('**', '*.*~')
  temp_files = Dir.glob(temp_filenames)

  File.delete(*temp_files)
end

