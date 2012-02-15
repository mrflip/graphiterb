#!/usr/bin/env ruby
require 'rubygems'
require 'graphiterb/script'
Configliere.use :commandline, :config_file
Settings.resolve!
Graphiterb::Monitors::System.new('system', :iters => 5, :time => 5).run! if $0 == __FILE__
