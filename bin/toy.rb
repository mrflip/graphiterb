#!/usr/bin/env ruby
require 'rubygems'
$: <<  File.dirname(__FILE__)+'/../lib'
require 'graphiterb'
Configliere.use :commandline, :config_file

Settings.read 'graphite.yaml'
Settings.resolve!
Log = Logger.new($stderr) unless defined?(Log)

monitor = Graphiterb::GraphiteLogger.new(:iters => 100, :time => 10)

loop do
  monitor.periodically{}
  sleep rand(1.0)
  puts '.'
end
  