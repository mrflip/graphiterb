#!/usr/bin/env ruby
$: << '../lib/'
require 'rubygems'
require 'graphiterb'
require 'configliere'
Configliere.use :commandline, :config_file, :define

#
# Usage:
#
#    nohup ~/ics/backend/graphiterb/bin/file_monitor.rb --workdir=/data/ripd/com.tw --update_delay=60 > /data/log/file_monitor.log 2>&1 &
#
#
Settings.read 'graphite.yaml'
Settings.define :workdir, :description => "Base directory where scrapers store files. (Ex: /data/ripd/com.tw)", :default => "/data/ripd/com.tw"
Settings.resolve!

# WORK_DIR = '/data/ripd/com.tw/'
Log = Logger.new($stderr) unless defined?(Log)

class FileMonitor

  def initialize
    @current_file = Hash.new
    @last_size    = Hash.new
    handles.each{|handle| current_file(handle); @last_size[handle] = current_file_size(handle) }
  end

  def today
    Time.now.strftime("%Y%m%d")
  end

  def handles
    @handles = []
    Dir[work_path('*')].sort.each do |full_handle_path|
      handle = File.basename(full_handle_path)
      current_file(handle) if @current_file[handle].nil?
      @handles << handle if ( (not Dir[work_path(handle,today)].empty?) || (current_file_size(handle) != 0) )
    end
    @handles
  end

  def work_path *paths
    File.join(Settings.workdir, *paths)
  end

  def files handle
    Dir[work_path(handle, today, '*')].reject{|f| File.directory?(f) }.sort
  end

  def current_file handle
    @current_file[handle] = self.files(handle).last || @current_file[handle]
  end

  def get_sizes handle
    files(handle).map{|file| File.size(file) rescue nil }.compact
  end

  def current_file_size handle
    file = current_file(handle) or return 0
    File.size(file)
  end

  def num_files handle
    get_sizes(handle).length
  end

  def avg_size handle
    sizes = get_sizes(handle)
    tot_size = sizes.inject(0){|tot, size| tot += size}
    return (tot_size/sizes.length).to_i
  end

  def max_size handle
    sizes = get_sizes(handle)
    sizes.empty? ? 0 : sizes.max
  end

  def min_size handle
    sizes = get_sizes(handle)
    sizes.empty? ? 0 : sizes.min
  end

  def size_rate handle
    return 0 if @current_file[handle] == ""
    if current_file_size(handle) < @last_size[handle]
      @last_size[handle] = current_file_size(handle)
      return @last_size[handle]
    end
    rate = current_file_size(handle) - @last_size[handle]
    @last_size[handle] = current_file_size(handle)
    return rate
  end

  def hostname
    @hostname ||= `hostname`.chomp.gsub(".","_")
  end

  def send_metrics
    monitor = Graphiterb::GraphiteLogger.new(:iters => nil, :time => Settings.update_delay)
    loop do
      metrics = []
      monitor.periodically do |metrics, iter, since|
        handles.each do |handle|
          hostname_handle = "scraper.#{hostname}.com_tw.#{handle.chomp.gsub(".","_")}"
          sizes = get_sizes(handle)
          @last_size[handle] ||= current_file_size(handle)
          rate = size_rate(handle)
          metrics << ["#{hostname_handle}.current_file_size", current_file_size(handle)]
          metrics << ["#{hostname_handle}.size_rate",         rate]
          metrics << ["#{hostname_handle}.num_files",         num_files(handle)] unless sizes.empty?
          metrics << ["#{hostname_handle}.avg_file_size",     avg_size(handle)]  unless sizes.empty?
          metrics << ["#{hostname_handle}.min_file_size",     min_size(handle)]  unless sizes.empty?
          metrics << ["#{hostname_handle}.max_file_size",     max_size(handle)]  unless sizes.empty?
        end
      end
      sleep Settings.update_delay
    end
  end

end

Settings.die "Update delay is #{Settings.update_delay} seconds.  You probably want something larger." if Settings.update_delay < 60

FileMonitor.new.send_metrics
