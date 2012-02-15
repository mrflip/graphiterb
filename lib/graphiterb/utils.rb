require 'rubygems'
require 'socket'
require 'configliere'
require 'active_support'

require 'graphiterb/utils/log'

module Graphiterb

  Error               = Class.new(StandardError)
  NotImplementedError = Class.new(Error)
  
  module Utils
    autoload :SystemInfo, 'graphiterb/utils/system'
  end
end

