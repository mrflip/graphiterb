#!/usr/bin/env ruby
require 'rubygems'
$: <<  File.dirname(__FILE__)+'/../lib'
require 'graphiterb'
Configliere.use :commandline, :config_file

Settings.read 'graphite.yaml'
Settings.resolve!
Log = Logger.new($stderr) unless defined?(Log)

monitor = Graphiterb::GraphiteLogger.new(:iters => nil, :time => 5)

handle = 'simple_toy'

loop do
  monitor.periodically do |metrics, iter, since|
    metrics << ["scraper.toy.#{handle}.iter", iter]
    metrics << ["scraper.toy.#{handle}.iter", iter]
    metrics << ["scraper.toy.#{handle}.iter", iter]
    metrics << ["scraper.toy.#{handle}.iter", iter]
  end
  delay = 2
  sleep delay
  print delay.to_s+"\t"
end

