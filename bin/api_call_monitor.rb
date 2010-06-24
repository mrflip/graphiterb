#!/usr/bin/env ruby
require 'rubygems'
$: <<  File.dirname(__FILE__)+'/../lib'
require 'graphiterb'
require 'configliere'
Configliere.use :commandline, :config_file

Settings.read 'graphite.yaml'
Settings.resolve!
Log = Logger.new($stderr) unless defined?(Log)

class ApiCallMonitor

  def initialize
    @current_calls=Hash.new
    @prev_total=Hash.new
    @apis= %w(trstrank wordbag influence conversation)
  end

  def total_calls api
    total_calls = `cat /var/www/apeyeye/shared/log/apeyeye-access.log | grep 'GET /soc/net/tw/#{api}' | wc -l`
    @current_calls[api]=total_calls

    return @current_calls[api]
  end

  def rate api
    @prev_total[api]=@current_calls[api] if @prev_total[api].nil?
    rate = @current_calls[api].to_i - @prev_total[api].to_i
    @prev_total[api]=@current_calls[api]
    return rate
  end

  def hostname
    @hostname ||= `hostname`.chomp.gsub(".","_")
  end

  def send_metrics
    monitor = Graphiterb::GraphiteLogger.new(:iters => nil, :time => Settings.update_delay)
    loop do
      monitor.periodically do |metrics, iter, since|
        @apis.each do |api|
          total_calls(api)
          metrics << ["apeyeye.#{hostname}.#{api}.accesses",rate(api)]
        end
    end
      sleep Settings.update_delay
    end
  end

end

Settings.die "Update delay is #{Settings.update_delay} seconds.  You probably want something larger." if Settings.update_delay < 60

ApiCallMonitor.new.send_metrics
