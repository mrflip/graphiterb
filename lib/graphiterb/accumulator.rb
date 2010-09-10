module Graphiterb

  # An accumulator that uses a Redis database as a fast store.
  #
  #   a = Accumulator.new
  #   a.increment('my_value')
  #
  # It's assumed that the Redis database is local and on the default
  # port, but pass in :host or :port (or any other options Redis.new
  # understands) to change this.
  #
  # By default incrementing 'my_value' which actually increment a
  # counter stored at the key
  # 'graphiterb_accumulator:my_value:HOSTNAME'.
  #
  # See Graphiterb::Monitors::AccumulationsConsumer for the periodic
  # monitor that will consume the accumulated counts.
  class Accumulator

    # The Redis database.
    attr_accessor :redis

    # The Redis namespace used for the accumulators.
    attr_accessor :accumulators

    # The top-level scope under which to accumulate.
    attr_accessor :main_scope

    # Provides methods for finding out about the node this code is
    # running on.
    include Graphiterb::Utils::SystemInfo

    # Initialize a new Accumulator.
    #
    # Takes the same options as Redis.new.
    #
    # @param [String] main_scope
    # @param [Hash] options
    def initialize main_scope, options={}
      require 'redis'
      require 'redis-namespace'
      @main_scope   = main_scope
      @redis        = Redis.new(options)
      @accumulators = Redis::Namespace.new('graphiterb_accumulators', :redis => redis)
    end

    # Increment the Graphite target +args+ by the given +amount+.
    #
    # The target will be automatically scoped, see Accumulator#scope.
    #
    # @param [Integer] amount      
    # @param [Array<String>, String] args
    def increment_by amount, *args
      accumulators.incrby(scope(*args), amount)
    end
    
    # Increment the Graphite target +args+.
    #
    # @param [Array<String>, String] args
    def increment *args
      accumulators.incr(scope(*args))
    end

    # Return the scoped accumulator name.
    #
    # This will be a valid string target that can be passed directly
    # to Graphite.
    #
    #   a = Accumulator.new('scrapers')
    #   a.scope('foo.bar', 'baz')
    #   #=> 'scrapers.foo.bar.baz.ip-120.112.4.383'
    #
    # @param [Array<String>, String] args
    # @return [String]
    def scope *args
      [main_scope, args, hostname].flatten.compact.map(&:to_s).join('.')
    end

  end
end

