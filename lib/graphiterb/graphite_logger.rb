require 'monkeyshines/monitor'

module Graphiterb
  
  class GraphiteLogger < Monkeyshines::Monitor::PeriodicMonitor
    
    def initialize *args
      super *args
    end
    
    def periodically &block
      super do |iter, time_since_last|
        puts iter
      end
    end
    
  end
  
end