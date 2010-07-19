require 'monkeyshines/monitor'

module Graphiterb
  class GraphiteLogger < Monkeyshines::Monitor::PeriodicMonitor
    # Connection to graphite server
    attr_reader :sender
    # the leading segment for sent metrics -- eg 'scrapers' or 'api_calls'
    attr_reader :main_scope

    def initialize main_scope, *args
      super *args
      self.time_interval ||= Settings.update_delay
      @sender     = GraphiteSender.new
      @main_scope = main_scope
    end

    def periodically &block
      super do |iter, since|
        metrics = []
        block.call(metrics, iter, since)
        sender.send *metrics
      end
    end

    def hostname
      @host ||= `hostname`.chomp.gsub(".","_")
    end

    def scope_name *scope
      [main_scope, scope].flatten.reject(&:blank?).join('.')
    end

    def run!
      loop do
        periodically do |metrics, iter, since|
          get_metrics metrics, iter, since
        end
        sleep 1
      end
    end
  end
end
