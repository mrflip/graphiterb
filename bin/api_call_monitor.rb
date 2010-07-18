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
    @current_total=Hash.new
    @prev_total=Hash.new
    @apis= %w(trstrank wordbag influence conversation)
    @errors = %w(4.. 5..)
  end

  def calls api
    total_calls = `cat /var/www/apeyeye/shared/log/apeyeye-access.log | grep 'GET /soc/net/tw/#{api}' | wc -l`
    @current_total[api]=total_calls

    return @current_total[api]
  end

  def errors error_code
    log_cat =  `cat /var/www/apeyeye/shared/log/apeyeye-access.log | grep 'GET /soc/net/tw/.*HTTP/1\.[0-1]..#{error_code}' | wc -l`
    @current_total[error_code] = log_cat
  end

  def rate item
    @prev_total[item]=@current_total[item] if @prev_total[item].nil?
    rate = @current_total[item].to_i - @prev_total[item].to_i
    @prev_total[item]=@current_total[item]
    return rate if rate >= 0 else 0
  end

  def hostname
    @hostname ||= `hostname`.chomp.gsub(".","_")
  end

  def send_metrics
    monitor = Graphiterb::GraphiteLogger.new(:iters => nil, :time => Settings.update_delay)
    loop do
      monitor.periodically do |metrics, iter, since|
        @apis.each do |api|
          calls(api)
          metrics << ["apeyeye.#{hostname}.#{api}.accesses",rate(api)]
        end
        @errors.each do |code|
          errors(code)
          metrics << ["apeyeye.#{hostname}.#{code.gsub('.','x')}.errors", rate(code)]
        end
      end
      sleep Settings.update_delay
    end
  end

end

Settings.die "Update delay is #{Settings.update_delay} seconds.  You probably want something larger." if Settings.update_delay < 60

ApiCallMonitor.new.send_metrics
