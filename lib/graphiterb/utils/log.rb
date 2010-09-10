require 'logger'

module Graphiterb

  class << self; attr_accessor :log end

  def self.instantiate_logger!
    Graphiterb.log ||= Logger.new(Settings[:log] || STDOUT)
    Graphiterb.log.datetime_format = "%Y%m%d-%H:%M:%S "
    Graphiterb.log.level           = Logger::INFO
  end

end
Graphiterb.instantiate_logger!
