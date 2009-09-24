require 'rubygems'
require 'rake'

require 'lib/datapathy'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "datapathy"
    gem.summary = "The stupid-simple ORM"
    gem.email = "psadauskas@gmail.com"
    gem.homepage = "http://github.com/paul/datapathy"
    gem.authors = ["Paul Sadauskas"]
    gem.version = Datapathy.version

    gem.add_dependency "activesupport", "~> 3.0.pre"
    gem.add_dependency "uuidtools", "~> 2.0"
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts << ['--options', 'spec/spec.opts']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

task :gem => :build

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "datapathy #{Datapathy.version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

