#!/usr/bin/env ruby
require 'rubygems'
$: <<  File.dirname(__FILE__)+'/../lib'
require 'graphiterb'
Configliere.use :commandline, :config_file
Settings.resolve!

class ToyMonitor < Graphiterb::Monitors::PeriodicMonitor
  def get_metrics metrics, since
    metrics << [scope('random', graphite_identifier), rand]
  end
end

ToyMonitor.new('toy').run! if $0 == __FILE__
