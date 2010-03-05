module Graphiterb
  #
  # @example:
  #   # in initialize, perhaps
  #   self.sender = GraphiteSender
  #
  #   # ... somewhere else ...
  #   sender.send( ['webserver.pages', pages_this_hour], ['webserver.errors', errors_this_hour] )
  #
  class GraphiteSender

    def initialize
      open!
    end

    def open!
      begin
        warn "Connecting to server #{Settings.carbon_server} port #{Settings.carbon_port}"
        @socket = TCPSocket.new(Settings.carbon_server, Settings.carbon_port)
      rescue StandardError => e
        Log.warn "Couldn't connect to server #{Settings.carbon_server} port #{Settings.carbon_port}: #{e.class} #{e}"
      end
    end
    
    def socket
      @socket ||= open!
    end

    def safely &block
      begin
        block.call
      rescue StandardError => e
        Log.warn "Sleeping #{Settings.on_error_delay}: #{e.class} #{e}"
        sleep Settings.on_error_delay
        @socket = nil
        return nil
      end
    end

    def timestamp
      Time.now.to_i
    end

    def send *metrics
      now = timestamp
      message = metrics.map{|metric, val| [metric, val, now].join(" ") }.join("\n")
      safely do
        socket.puts(message)
        Log.debug "Sent:\n#{message}\n#{'-'*80}"
      end
    end
  end
end
