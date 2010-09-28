require 'graphiterb/utils'

module Graphiterb
  autoload :Monitors, 'graphiterb/monitors'
  autoload :Sender,   'graphiterb/sender'
  autoload :Accumulator, 'graphiterb/accumulator'
end

Settings.use :define, :config_file

Settings.define :log,                                     :description => "Log output for Graphiterb"
Settings.define :carbon_server,  :default => 'localhost', :description => "Host address for carbon database server", :required => true
Settings.define :carbon_port,    :default => '2003',      :description => "Port for carbon database server", :required => true
Settings.define :update_delay,   :default => 30,          :description => "How long to wait between updates. Must be faster than the value in the graphite/conf/storage-schemas", :required => true, :type => Integer
Settings.define :on_error_delay, :default => 0.1,         :description => "How long to wait on connect errors", :required => true, :type => Float
Settings.define :node_name_file, :default => '/etc/node_name', :description => "Path to a file which contains the name of this node", :type => String
Settings.read '/etc/graphiterb/graphiterb.yaml' if File.exist? '/etc/graphiterb/graphiterb.yaml'
Settings.resolve!
