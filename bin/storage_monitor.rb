#!/usr/bin/env ruby
require 'rubygems'
$: <<  File.dirname(__FILE__)+'/../lib'
require 'graphiterb'
Configliere.use :commandline, :config_file

Settings.read 'graphite.yaml'
Settings.resolve!
Log = Logger.new($stderr) unless defined?(Log)

class AvailSpaceMonitor
  def hostname
    @hostname ||= `hostname`.chomp
  end
  
  def diskfree
    @diskfree ||= `df`
  end
  
  def send_metrics
    monitor = Graphiterb::GraphiteLogger.new(:iters => nil, :time => Settings.update_delay)
    loop do
      diskfree.split("\n").grep(/^\/dev\//).each do |disk|
        handle, size, spaceused, spacefree, percentfree, location = disk.split(/\s+/)
        monitor.periodically do |metrics, iter, since|
          metrics << ["system.#{hostname}#{handle.gsub(/\//,'.')}.available", spacefree.to_i]
        end
      end
      sleep Settings.update_delay
    end
  end
  
end

AvailSpaceMonitor.new.send_metrics
