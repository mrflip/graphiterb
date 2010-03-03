require 'monkeyshines/monitor'

module Graphiterb

  class GraphiteLogger < Monkeyshines::Monitor::PeriodicMonitor
    attr_accessor :sender
    def initialize *args
      super *args
      self.sender = GraphiteSender.new
    end

    def periodically &block
      super do |iter, since|
        metrics = []
        block.call(metrics, iter, since)
        # should be:
        sender.send *metrics
        # puts metrics.inspect
      end
    end

  end

end
