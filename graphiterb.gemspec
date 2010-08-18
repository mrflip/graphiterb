# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{graphiterb}
  s.version = "0.2.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Philip (flip) Kromer (@mrflip)"]
  s.date = %q{2010-08-18}
  s.description = %q{Uses http://github.com/mrflip/configliere and http://graphite.wikidot.com}
  s.email = %q{info@infochimps.org}
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
     "examples/api_call_monitor.rb",
     "examples/file_monitor.rb",
     "examples/loadavg_graphite_sender.rb",
     "examples/run_servers.sh",
     "examples/storage_monitor.rb",
     "examples/toy.rb",
     "graphiterb.gemspec",
     "lib/graphiterb.rb",
     "lib/graphiterb/monitors.rb",
     "lib/graphiterb/monitors/directory_tree.rb",
     "lib/graphiterb/monitors/disk_space.rb",
     "lib/graphiterb/monitors/system.rb",
     "lib/graphiterb/script.rb",
     "lib/graphiterb/sender.rb",
     "lib/graphiterb/utils.rb",
     "lib/graphiterb/utils/log.rb",
     "lib/graphiterb/utils/system.rb",
     "spec/graphiterb_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/infochimps/graphiterb}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Fast Ubiquitous Dashboard Logs with Graphite (http://graphite.wikidot.com)}
  s.test_files = [
    "spec/graphiterb_spec.rb",
     "spec/spec_helper.rb",
     "examples/toy.rb",
     "examples/storage_monitor.rb",
     "examples/loadavg_graphite_sender.rb",
     "examples/file_monitor.rb",
     "examples/api_call_monitor.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<configliere>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<configliere>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<configliere>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

