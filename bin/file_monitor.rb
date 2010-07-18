#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib/'
require 'rubygems'
require 'graphiterb'
require 'graphiterb/graphite_logger'
require 'configliere'
require 'active_support'
Configliere.use :commandline, :config_file, :define

#
# Usage:
#
#    nohup ~/ics/backend/graphiterb/bin/file_monitor.rb --work_dir=/data/ripd/com.tw --carbon_server=whatever --update_delay=120 > /data/log/file_monitor.log 2>&1 &
#
Settings.read 'graphite.yaml'
Settings.define :work_dir, :description => "Base directory where scrapers store files. (Ex: /data/ripd/com.tw)", :required => true
Settings.resolve!

Log = Logger.new($stderr) unless defined?(Log)
WC_EXEC = '/usr/bin/wc'

class FilePool
  # Path to sample for files
  attr_accessor :path
  # wildcard sequence for files under the current directory
  attr_accessor :glob
  # A recent file was modified within this window
  attr_accessor :recent_window
  # Only consider the last this-many files
  MAX_FILES = 30

  def initialize path, glob='**/*', options={}
    self.path      = path
    self.glob      = glob
  end

  # Name for this pool, suitable for inclusion in a metrics handle
  def name
    path.gsub(/\./,'_').gsub(%r{/}, '.').gsub(%r{(^\.|\.$)},'')
  end

  #
  # Lists all files in the pool
  # @param filter_block files only keeps filenames that pass this filter
  #
  def files &filter_block
    Dir[File.join(path, glob)].
      reject{|f| File.directory?(f) }.
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
    rescue RuntimeError => e ; warn(e.backtrace, e) ; return nil ; end
  end

  def line_counts &filter_block
    files  = files(&filter_block) ; return 0 if files.blank?
    result = lines_in_result_of(WC_EXEC, '-l', *files) or return 0
    counts = result.map{|wc| wc =~ /^\s*(\d+)\s+/ and $1 }.compact
    counts.map(&:to_i).sum
  end

  def self.recent? file
    (Time.now - File.mtime(file)) < 1.hour
  end
  def self.recency_filter
    Proc.new{|file| recent?(file) }
  end
end

class FileMonitor < Graphiterb::GraphiteSystemLogger
  attr_accessor :path
  attr_accessor :pools

  def initialize *args
    super *args
    self.path = Settings.work_dir
    self.pools = {}
    populate_pools!
  end

  def populate_pools!
    Dir[File.join(path, '*')].select{|d| File.directory?(d) }.each do |dir|
      self.pools[dir] ||= FilePool.new(dir, '20*/**/*.tsv')
    end
  end

  def get_metrics metrics, iter, since
    recent = FilePool.recency_filter
    pools.each do |pool_path, pool|
      metrics << [scope_name(pool.name, hostname, 'active_files'),     pool.num_files(&recent) ]
      metrics << [scope_name(pool.name, hostname, 'active_file_size'), pool.size(&recent) ]
      metrics << [scope_name(pool.name, hostname, 'line_counts'),      pool.line_counts(&recent) ]
    end
  end
end

Settings.die "Update delay is #{Settings.update_delay} seconds.  You probably want something larger: some of the metrics are expensive." if Settings.update_delay < 1
FileMonitor.new('scraper', :iters => nil, :time => Settings.update_delay).run!
