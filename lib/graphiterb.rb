require 'socket'
require 'logger'

require 'configliere'
Configliere.use :define
Settings.define :carbon_server,  :default => 'localhost', :description => "Host address for carbon database server", :required => true
Settings.define :carbon_port,    :default => '2003',      :description => "Port for carbon database server", :required => true
Settings.define :update_delay,   :default => 60,          :description => "How long to wait between updates", :required => true, :type => Integer
Settings.define :on_error_delay, :default => 60,         :description => "How long to wait on connect errors", :required => true, :type => Integer

require 'graphiterb/graphite_sender'
