require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "datapathy"
    gem.summary = "The stupid-simple ORM"
    gem.email = "psadauskas@gmail.com"
    gem.homepage = "http://github.com/paul/datapathy"
    gem.authors = ["Paul Sadauskas"]
    gem.version = "0.5.0"

    gem.add_dependency "activesupport", "~> 3.0.0"
    gem.add_dependency "activemodel", "~> 3.0.0"
    gem.add_development_dependency "uuidtools", "~> 2.0"
    gem.add_development_dependency "rspec"
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

