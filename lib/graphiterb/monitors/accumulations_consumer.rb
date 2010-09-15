module Graphiterb
  module Monitors

    # A monitor which consumes counts accumulated in a Redis store by
    # Graphiterb::Accumulator.
    class AccumulationsConsumer < Graphiterb::Monitors::PeriodicMonitor

      # The Redis database.
      attr_accessor :redis

      # The name of the Redis namespace (a string) in which
      # accumulations are stored (defaults to 'graphiterb')
      attr_accessor :namespace

      # The Redis namespace used for the accumulators.
      attr_accessor :accumulators

      # A regular expression that must match the Graphite target
      # (defaults to always matching).
      attr_accessor :regexp

      # Instantiate a new AccumulationsConsumer.
      #
      # Options are passed to Redis.new as well as
      # Graphiterb::Monitors::PeriodicMonitor.
      #
      # Include the :namespace option to tell this consumer which
      # Redis namespace to consume keys from (defaults to
      # 'graphiterb').
      #
      # Include the :regexp option if you want this monitor to only
      # consume keys corresponding to Graphite targets which match the
      # regexp.  This is useful for having multiple
      # AccumulationsConsumer monitors running with different
      # frequencies tracking different Graphite target families.
      def initialize options={}
        require 'redis'
        require 'redis-namespace'
        @redis        = Redis.new(options)
        @namespace    = options[:namespace] || 'graphiterb'
        @accumulators = Redis::Namespace.new(namespace, :redis => @redis)
        @regexp       = options[:regexp] || /.*/
        super('fake_scope', options) # FIXME shouldn't have to use a fake scope
      end

      # Uses Redis' +getset+ call to retrieve total accumulated counts
      # from Redis and reset them to 0 atomically.
      def get_metrics metrics, since
        accumulators.keys.each do |target|
          next unless regexp =~ target
          current_count = accumulators.getset(target, 0)  rescue 0.0
          rate          = current_count.to_f / since.to_f rescue 0.0
          metrics << [target, rate] # no need to scope as targets are pre-scoped
        end
      end
      
    end
  end
end

