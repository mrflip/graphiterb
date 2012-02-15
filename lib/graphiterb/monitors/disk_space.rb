module Graphiterb
  module Monitors

    # A monitor for how much space is available on a node.
    class DiskSpace < Graphiterb::Monitors::PeriodicMonitor

      # Runs and parses `df'.
      #
      #   disk_space.df
      #   #=> [["/dev/sda", "39373712", "20488716", "16884908", "55%", "/"], ["/dev/sdb", "920090332", "397413344", "475939088", "46%", "/home"]]
      #
      # @return [Array<Array>]
      def df
        `/bin/df`.chomp.split("\n").
          grep(%r{^/dev/}).
          map{|line| line.split(/\s+/) } rescue []
      end

      # Calls +df+ and adds the space available metric.
      def get_metrics metrics, since
        #         "/dev/sdb1", "39373712", "20488716", "16884908", "55%", "/"
        df.each do |handle, size, spaceused, spacefree, percentfree, location|
          disk_name = handle.gsub(/^\//, '').split('/')
          metrics << [scope(graphite_identifier, disk_name, 'available'), spacefree.to_i]
        end
      end
    end
  end
end
