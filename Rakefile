require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rubyforge'

desc 'Default: run unit tests.'
task :default => :test

task :clean => [:clobber_rdoc, :clobber_package]

desc 'Test the yandex_metrika plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the yandex_metrika plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'YandexMetrika'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

gem_spec = eval(File.read('yandex_metrika.gemspec'))

begin
  gem 'ci_reporter'
  require 'ci/reporter/rake/test_unit'
  task :bamboo => "ci:setup:testunit"
rescue LoadError
end

task :bamboo => [ :package, :test ]
