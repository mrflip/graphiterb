require 'rubygems'
require 'graphiterb'

Configliere.use :commandline, :config_file, :define
Log = ::Logger.new($stderr) unless defined?(Log)
Settings.resolve!
