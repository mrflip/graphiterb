module Graphiterb
  module Utils

    # A module which provides information about the node this code is
    # executing on.
    #
    # Maybe it's worth bringing Ohai into this.  I'm not sure.
    module SystemInfo

      def hostname
        @hostname ||= `hostname`.chomp.gsub(/\./,"_")
      end

      def node_name
        @node_name ||= Settings[:node_name_file] && File.exist?(Settings[:node_name_file]) && File.read(Settings[:node_name_file]).chomp.strip.gsub(/\./, '_')
      end

      def graphite_identifier
        node_name || hostname
      end
    end
  end
end

