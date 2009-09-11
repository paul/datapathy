# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{datapathy}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Sadauskas"]
  s.date = %q{2009-09-11}
  s.email = %q{psadauskas@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/datapathy.rb",
     "lib/datapathy/adapters/abstract_adapter.rb",
     "lib/datapathy/adapters/memory_adapter.rb",
     "lib/datapathy/model.rb",
     "lib/datapathy/query.rb",
     "spec/datapathy_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/paul/datapathy}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{TODO}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/datapathy_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0"])
      s.add_runtime_dependency(%q<uuidtools>, ["~> 2.0"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3.0"])
      s.add_dependency(%q<uuidtools>, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.0"])
    s.add_dependency(%q<uuidtools>, ["~> 2.0"])
  end
end
