module Graphiterb
  module Utils

    # A module which provides information about the node this code is
    # executing on.
    #
    # Maybe it's worth bringing Ohai into this.  I'm not sure.
    module SystemInfo

      def hostname
        @hostname ||= `hostname`.chomp.gsub(".","_")
      end
      
    end
  end
end

