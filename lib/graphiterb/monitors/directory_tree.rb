module Graphiterb
  module Monitors

    # A class for monitoring the contents of a directory.
    #
    # Will only monitor files modified within the last hour by
    # default.
    class DirectoryTree < Graphiterb::Monitors::PeriodicMonitor

      # The root of the directory tree being monitored.
      attr_accessor :root

      # A regular expression filter that must be matched by files
      # within the root directory to be counted.
      attr_accessor :filter_re

      def initialize main_scope, root, options={}
        super(main_scope, options)
        self.root      = File.expand_path(root)
        self.filter_re = self.options[:filter_re] || /.*/
      end

      def dirs
        @dirs ||= Dir[File.join(root, '*')].select{|d| File.directory?(d) }.map { |path| Directory.new(path, filter_re) }
      end

      def get_metrics metrics, since
        recent = Directory.recency_filter
        dirs.each do |dir|
          metrics << [scope(dir.name, 'num_files', graphite_identifier), dir.num_files(&recent)   ]
          metrics << [scope(dir.name, 'size', graphite_identifier),      dir.size(&recent)        ]
          metrics << [scope(dir.name, 'lines', graphite_identifier),     dir.line_counts(&recent) ]
        end
      end

      # A class for monitoring the contents of a directory.
      class Directory
        
        # Path to sample for files
        attr_accessor :path
        
        # Wildcard sequence for files under the current directory.
        attr_accessor :filter_re
        
        # A recent file was modified within this window.
        attr_accessor :recent_window
        
        # Only consider the last this-many files.
        MAX_FILES = 30

        def initialize path, filter_re=/.*/, options={}
          self.path      = path
          self.filter_re = filter_re
        end

        # Name for this pool, suitable for inclusion in a Graphite
        # target.
        #
        # @return [String]
        def name
          path.gsub(/\./,'_').gsub(%r{/}, '.').gsub(%r{(^\.|\.$)},'')
        end

        #
        # Lists all files in the pool
        # @param filter_block files only keeps filenames that pass this filter
        #
        def files &filter_block
          Dir[File.join(path, '**/*')].
            reject{|f| File.directory?(f) }.
            select{|f| f =~ filter_re }.
            sort.reverse[0..MAX_FILES].
            select(&filter_block)
        end

        def num_files &filter_block
          files(&filter_block).count
        end

        def sizes &filter_block
          files(&filter_block).map{|f| File.size(f) rescue nil }.compact
        end
        
        def size &filter_block
          sizes(&filter_block).sum
        end
        
        def avg_size &filter_block
          sizes(&filter_block).sum.to_f / num_files(&filter_block).to_f
        end

        def lines_in_result_of command, *args
          begin
            escaped_args = args.map{|f| "'#{f}'" }
            result = `#{command} #{escaped_args.join(" ")}`.chomp
            result.split(/[\r\n]+/)
          rescue StandardError => e ; warn(e.backtrace, e) ; return nil ; end
        end

        def wc
          @wc ||= `which wc`.chomp
        end

        def line_counts &filter_block
          files  = files(&filter_block) ; return 0 if files.blank?
          result = lines_in_result_of(wc, '-l', *files) or return 0
          counts = result.map{|string| string =~ /^\s*(\d+)\s+/ and $1 }.compact
          counts.map(&:to_i).sum
        end

        def self.recent? file
          (Time.now - File.mtime(file)) < 3600
        end
        
        def self.recency_filter
          Proc.new{|file| recent?(file) }
        end
        
      end
    end
  end
end

