require 'logger'

module Graphiterb

  class << self; attr_accessor :log end

  # Create a Logger and point it at Graphiterb::LOG_FILE_DESTINATION which is
  # set in ~/.imwrc and defaults to STDERR.
  def self.instantiate_logger!
    Graphiterb.log ||= Logger.new(Settings[:log])
    Graphiterb.log.datetime_format = "%Y%m%d-%H:%M:%S "
    Graphiterb.log.level           = Logger::INFO
  end

end
Graphiterb.instantiate_logger!
