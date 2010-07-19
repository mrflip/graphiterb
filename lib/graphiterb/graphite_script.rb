require 'rubygems'
require 'graphiterb'
require 'wukong/extensions'
Configliere.use :commandline, :config_file, :define

Log = ::Logger.new($stderr) unless defined?(Log)

Settings.read 'graphite.yaml'
Settings.resolve!
