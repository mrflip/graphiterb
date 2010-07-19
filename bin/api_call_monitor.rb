#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib/'
require 'graphiterb'
require 'graphiterb/graphite_script'

WC_EXEC = '/usr/bin/wc'

class ApiCallMonitor < Graphiterb::GraphiteLogger
  API_CALLS_TO_MONITOR   = %w[trstrank wordbag influence conversation]
  ERROR_CODES_TO_MONITOR = %w[4.. 5..]

  def initialize *args
    super *args
    @current_total = Hash.new
    @prev_total    = Hash.new
  end

  def calls api
    total_calls = `cat /var/www/apeyeye/shared/log/apeyeye-access.log | grep 'GET /soc/net/tw/#{api}' | #{WC_EXEC} -l`
    @current_total[api] = total_calls
  end

  def errors error_code
    log_cat =  `cat /var/www/apeyeye/shared/log/apeyeye-access.log | grep 'GET /soc/net/tw/.*HTTP/1\.[0-1]..#{error_code}' | #{WC_EXEC} -l`
    @current_total[error_code] = log_cat
  end

  def rate item
    @prev_total[item] ||= @current_total[item]
    rate                = @current_total[item].to_i - @prev_total[item].to_i
    @prev_total[item]   = @current_total[item]
    [0, rate].max
  end

  def get_metrics metrics, iter, since
    API_CALLS_TO_MONITOR.each do |api|
      calls(api)
      metrics << [scope_name(hostname, api, 'accesses'), rate(api)]
    end
    ERROR_CODES_TO_MONITOR.each do |code|
      errors(code)
      metrics << [scope_name(hostname, code.gsub('.','x'), 'errors'), rate(code)]
    end
  end
end


warn "Update delay is #{Settings.update_delay} seconds.  You probably want something larger: some of these checks are data-intensive" if Settings.update_delay < 60
Settings.die "Update delay is #{Settings.update_delay} seconds.  You need to radio in at least as often as /usr/local/share/graphite/conf/storage-schemas says -- this is typically 5 minutes." if Settings.update_delay >= 300

ApiCallMonitor.new('apeyeye', :iters => nil, :time => Settings.update_delay).run!
