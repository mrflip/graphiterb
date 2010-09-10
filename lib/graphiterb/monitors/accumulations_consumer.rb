module Graphiterb
  module Monitors

    # A monitor which consumes counts accumulated in a Redis store by
    # Graphiterb::Accumulator.
    class AccumulationsConsumer < Graphiterb::Monitors::PeriodicMonitor

      # The Redis database.
      attr_accessor :redis

      # The Redis namespace used for the accumulators.
      attr_accessor :accumulators

      # Instantiate a new AccumulationsConsumer.
      #
      # Options are passed to Redis.new as well as
      # Graphiterb::Monitors::PeriodicMonitor.
      def initialize options={}
        require 'redis'
        require 'redis-namespace'
        @redis        = Redis.new(options)
        @accumulators = Redis::Namespace.new('graphiterb_accumulators', :redis => @redis)
        super('fake_scope', options)
      end

      # Uses Redis' +getset+ call to retrieve total accumulated counts
      # from Redis and reset them to 0 atomically.
      def get_metrics metrics, since
        accumulators.keys.each do |target|
          current_count = accumulators.getset(target, 0)  rescue 0.0
          rate          = current_count.to_f / since.to_f rescue 0.0
          metrics << [target, rate] # no need to scope as targets are pre-scoped
        end
      end
      
    end
  end
end

