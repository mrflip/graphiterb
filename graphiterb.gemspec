# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{graphiterb}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Philip (flip) Kromer (@mrflip)"]
  s.date = %q{2010-07-19}
  s.description = %q{Uses http://github.com/mrflip/configliere and http://graphite.wikidot.com}
  s.email = %q{info@infochimps.org}
  s.executables = ["run_servers.sh", "storage_monitor.rb", "api_call_monitor.rb", "loadavg_graphite_sender.rb", "toy.rb", "file_monitor.rb"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.textile"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "CHANGELOG",
     "LICENSE",
     "README.textile",
     "Rakefile",
     "VERSION",
     "bin/api_call_monitor.rb",
     "bin/file_monitor.rb",
     "bin/loadavg_graphite_sender.rb",
     "bin/run_servers.sh",
     "bin/storage_monitor.rb",
     "bin/toy.rb",
     "graphiterb.gemspec",
     "lib/graphiterb.rb",
     "lib/graphiterb/graphite_logger.rb",
     "lib/graphiterb/graphite_script.rb",
     "lib/graphiterb/graphite_sender.rb",
     "lib/graphiterb/graphite_system_logger.rb",
     "spec/graphiterb_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/mrflip/graphiterb}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Fast Ubiquitous Dashboard Logs with Graphite (http://graphite.wikidot.com)}
  s.test_files = [
    "spec/graphiterb_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

