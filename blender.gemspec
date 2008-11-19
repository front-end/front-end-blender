# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{blender}
  s.version = "0.22"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Blake Elshire", "Chris Griego"]
  s.date = %q{2008-11-18}
  s.default_executable = %q{blend}
  s.description = %q{Blender is like ant or make for the front-end. It aggregates and compresses CSS and/or JavaScript assets for a site into efficient, production-ready files.}
  s.email = %q{blender@front-end-architect.com}
  s.executables = ["blend"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/blend", "lib/front_end_architect/blender.rb", "lib/front_end_architect/hash.rb", "lib/yui/LICENSE", "lib/yui/yuicompressor.jar"]
  s.has_rdoc = true
  s.homepage = %q{http://www.front-end-architect.com/blender/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.requirements = ["Java, v1.4 or greater"]
  s.rubyforge_project = %q{blender}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Blender outputs efficient, production-ready CSS and/or JavaScript assets.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mime-types>, [">= 1.15"])
      s.add_runtime_dependency(%q<colored>, [">= 1.1"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<mime-types>, [">= 1.15"])
      s.add_dependency(%q<colored>, [">= 1.1"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<mime-types>, [">= 1.15"])
    s.add_dependency(%q<colored>, [">= 1.1"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
