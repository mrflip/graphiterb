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
          next unless line =~ /^Mem: *(\d+)k *total, *(\d+)k *used, *(\d+)k *free/
          total = $1.to_f
          return [$2, $3].map do |bytes|
            bytes.to_f / total rescue 0.0
          end
        end
        [0,0]
      end

      def swap lines
        lines.each do |line|
          next unless line =~ /^Swap: *(\d+)k *total, *(\d+)k *used, *(\d+)k *free/
          total = $1.to_f
          return [$2, $3].map do |bytes|
            bytes.to_f / total rescue 0.0
          end
        end
        [0,0]
      end

      def get_metrics metrics, since
        df.each do |handle, size, spaceused, spacefree, percentused, location|
          disk_name = handle.gsub(/^\//, '').split('/')
          percent_free = (100.0 * spaceused.to_f / (spaceused.to_f + spacefree.to_f)) rescue 0.0
          metrics << [scope(hostname, disk_name, 'available'), percent_free]
        end

        lines = top
        
        metrics << [scope(hostname, 'cpu', 'avg_usage'),   cpu(lines)]

        proc_total, proc_running = processes(lines)
        metrics << [scope(hostname, 'processes', 'total'),   proc_total   ]
        metrics << [scope(hostname, 'processes', 'running'), proc_running ]

        mem_used, mem_free = memory(lines)
        swap_used, swap_free = swap(lines)
        
        metrics << [scope(hostname, 'memory', 'used'), mem_used  ]
        metrics << [scope(hostname, 'memory', 'free'), mem_free  ]
        metrics << [scope(hostname, 'swap', 'used'),   swap_used ]
        metrics << [scope(hostname, 'swap', 'free'),   swap_free ]
      end
      
    end
  end
end
