#!/usr/bin/env ruby
require 'rubygems'
$: <<  File.dirname(__FILE__)+'/../lib'
require 'graphiterb'
Configliere.use :commandline, :config_file

Settings.read 'graphite.yaml'
Settings.resolve!
Log = Logger.new($stderr) unless defined?(Log)

class LoadavgGraphiteSender < GraphiteRb::GraphiteSender
  def loadavgs
    File.open('/proc/loadavg').read.strip.split[0..2]
  end

  def loadavgs_metrics 
    %w[1min 5min 15min].zip(loadavgs).map do |duration, avg|
      ["system_rb.loadavg_#{duration}", avg]
    end
  end

  def send_loop
    loop do
      send *loadavgs_metrics
      Log.info "Sleeping #{Settings.update_delay}"
      sleep Settings.update_delay.to_i
    end
  end
end

LoadavgGraphiteSender.new.send_loop
