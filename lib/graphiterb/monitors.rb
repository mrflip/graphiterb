module Graphiterb
  module Monitors

    autoload :DiskSpace,      'graphiterb/monitors/disk_space'
    autoload :System,         'graphiterb/monitors/system'
    autoload :DirectoryTree,  'graphiterb/monitors/directory_tree'
    autoload :AccumulationsConsumer, 'graphiterb/monitors/accumulations_consumer'

    # Accepts a lightweight call every iteration.
    #
    # Once either a time or an iteration criterion is met, executes the block
    # and resets the timer until next execution.
    #
    # Note that the +time_interval+ is measured *excution to execution* and not
    # in multiples of iter_interval. Say I set a time_interval of 300s, and
    # happen to iterate at 297s and 310s after start.  Then the monitor will
    # execute at 310s, and the next execution will happen on or after 610s.
    #
    # Also note that when *either* criterion is met, *both* criteria are
    # reset. Say I set a time interval of 300s and an +iter_interval+ of 10_000;
    # and that at 250s I reach iteration 10_000.  Then the monitor will execute
    # on or after 20_000 iteration or 550s, whichever happens first.
    #
    # Stolen from Monkeyshines::Monitor::PeriodicMonitor
    class PeriodicMonitor

      # The main scope under which the monitor's metrics will be
      # written.
      attr_accessor :main_scope

      # Maximum number of seconds that should elapse between running
      # the monitor.
      attr_accessor :time_interval

      # Maximum number of internal "iterations" that should elapse between running the monitor
      attr_accessor :iter_interval

      # The options hash the monitor was created with.
      attr_accessor :options

      # Internal metrics stored by the monitor.
      attr_accessor :last_time, :current_iter, :iter, :started_at

      # Provides methods for finding out about the node this code is
      # running on.
      include Graphiterb::Utils::SystemInfo

      # Create a new PeriodicMonitor
      def initialize main_scope, options={}
        self.main_scope    = main_scope
        self.started_at    = Time.now.utc.to_f
        self.last_time     = started_at
        self.iter          = 0
        self.current_iter  = 0
        self.options       = options
        self.time_interval = options[:time]  || 30 
        self.iter_interval = options[:iters] || 30 
      end

      # The Graphiterb::Sender used to communicate with the Graphite
      # server.
      #
      # @return [Graphiterb::Sender]
      def sender
        @sender ||= Graphiterb::Sender.new
      end

      # True if more than +iter_interval+ has elapsed since last
      # execution.
      def enough_iterations?
        iter % iter_interval == 0 if iter_interval
      end

      # True if more than +time_interval+ has elapsed since last execution.
      def enough_time? now
        (now - last_time) > time_interval if time_interval
      end

      # Time since monitor was created
      #
      # @return [Time]
      def since
        Time.now.utc.to_f - started_at
      end

      # Overall iterations per second
      #
      # @return [Float]
      def rate
        iter.to_f / since.to_f
      end
      
      # "Instantaneous" iterations per second
      #
      # @return [Float]
      def inst_rate now
        current_iter.to_f / (now-last_time).to_f
      end

      # Return the scope built from this monitor's +main_scope+ and
      # the given +names+.
      #
      #   monitor.main_scope
      #   #=> 'system.parameters'
      #   monitor.scope 'disk', 'space'
      #   #=> 'system.paramters.disk.space'
      #
      # @param [Array<String>] names
      # @return [String]
      def scope *names
        [main_scope, *names].flatten.reject(&:blank?).join('.')
      end

      # If the interval conditions are met, executes block; otherwise
      # just does bookkeeping and returns.
      #
      # @yield [Array<String>, Time]
      def periodically &block
        self.iter += 1
        self.current_iter += 1
        now       = Time.now.utc.to_f
        if enough_iterations? || enough_time?(now)
          metrics = []
          block.call(metrics, (now-last_time))
          sender.send(*metrics)
          self.last_time = now
          self.current_iter = 0
        end
      end

      # Add metrics to the +metrics+ array.
      #
      # This method is meant to be overridden by a sub-class (indeed,
      # it will raise an error if called directly).
      #
      # It should take an array of metrics and a time interval since
      # last ran and insert metrics into the array.")
      #
      # @param [Array<String>] metrics
      # @param [Time] since the last time the monitor ran
      def get_metrics metrics, since
        raise Graphiterb::NotImplementedError.new("Override the get_metrics method of the #{self.class} class")
      end

      # Run this monitor.
      #
      # Sleep for 1 second and then wake up and check if either enough
      # time (+time_interval+) or enough iterations (+iter_interval+)
      # have passed run +get_metrics+ if so.
      def run!
        loop do
          periodically do |metrics, since|
            get_metrics metrics, since
          end
          sleep 1
        end
      end
      
    end

  end
end
