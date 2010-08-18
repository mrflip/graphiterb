module Graphiterb
  module Monitors
    class System < Graphiterb::Monitors::PeriodicMonitor

      def top
        `top -b -n3`.chomp.split(/^top -/).last.split("\n") rescue []
      end

      def df
        `/bin/df`.chomp.split("\n").
          grep(%r{^/dev/}).
          map{|line| line.split(/\s+/) } rescue []
      end
      
      def cpu lines
        cpus             = 0.0
        total_percentage = 0.0
        lines.each do |line|
          next unless line =~ /^Cpu.* *: *([\d\.]+)%us/
          cpus += 1.0
          total_percentage += $1.to_f
        end
        total_percentage / cpus rescue 0.0
      end

      def processes lines
        lines.each do |line|
          next unless line =~ /^Tasks: *(\d+) *total, *(\d+) *running/
          return [$1, $2].map(&:to_i)
        end
        [0, 0]
      end

      def memory lines
        lines.each do |line|
          next unless line =~ /^Mem: *\d+k *total, *(\d+)k *used, *(\d+)k *free/
          return [$1, $2].map(&:to_i)
        end
        [0,0]
      end

      def swap lines
        lines.each do |line|
          next unless line =~ /^Swap: *\d+k *total, *(\d+)k *used, *(\d+)k *free/
          return [$1, $2].map(&:to_i)
        end
        [0,0]
      end


      def get_metrics metrics, since
        puts '=' * 80
        df.each do |handle, size, spaceused, spacefree, percentfree, location|
          disk_name = handle.gsub(/^\//, '').split('/')
          metrics << [scope(hostname, disk_name, 'available'), spacefree.to_i]
        end

        lines = top
        
        metrics << [scope(hostname, 'cpu', 'avg_usage'),   cpu(lines)]
        metrics << [scope(hostname, 'processes', 'count'), processes(lines)]

        mem_used, mem_free = memory(lines)
        swap_used, swap_free = swap(lines)
        
        metrics << [scope(hostname, 'memory', 'used'), mem_used ]
        metrics << [scope(hostname, 'memory', 'free'), mem_free ]
        metrics << [scope(hostname, 'swap', 'used'),   swap_used]
        metrics << [scope(hostname, 'swap', 'free'),   swap_free]
      end
      
    end
  end
end
