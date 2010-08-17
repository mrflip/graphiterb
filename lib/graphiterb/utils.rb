require 'rubygems'
require 'socket'
require 'configliere'

require 'graphiterb/utils/log'
require 'graphiterb/utils/extensions'

module Graphiterb

  Error               = Class.new(StandardError)
  NotImplementedError = Class.new(Error)
  
  module Utils
    autoload :SystemInfo, 'graphiterb/utils/system'
  end
end

