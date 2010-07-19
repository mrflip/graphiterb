#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib/'
require 'rubygems'
require 'graphiterb/graphite_script'

class AvailSpaceMonitor < Graphiterb::GraphiteLogger
  def diskfree
    `/bin/df`.chomp.split("\n").
      grep(%r{^/dev/}).
      map{|line| line.split(/\s+/) } rescue []
  end

  def get_metrics metrics, iter, since
    diskfree.each do |handle, size, spaceused, spacefree, percentfree, location|
      metrics << ["system.#{hostname}#{handle.gsub(/\//,'.')}.available", spacefree.to_i]
    end
  end
end

warn "Update delay is #{Settings.update_delay} seconds.  You probably want something larger: some of the metrics are expensive." if Settings.update_delay < 30
warn "Update delay is #{Settings.update_delay} seconds.  You probably want something smaller: need to report in faster than the value in the graphite/conf/storage-schemas." if Settings.update_delay >= 60

AvailSpaceMonitor.new('system').run!
