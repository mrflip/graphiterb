#!/usr/bin/env ruby
$: << '../lib/'
require 'rubygems'
require 'graphiterb'
require 'configliere'
Configliere.use :commandline, :config_file, :define

Settings.read 'graphite.yaml'
Settings.define :workdir, :description => "Base directory where scrapers store files. (Ex: /data/ripd/com.tw)", :default => "/data/ripd/com.tw"
Settings.resolve!

# WORK_DIR = '/data/ripd/com.tw/'
Log = Logger.new($stderr) unless defined?(Log)

class FileMonitor

  def initialize
    @current_file = Hash.new
    @last_size = Hash.new
    return if handles.empty?
    handles.each{|handle| current_file(handle); @last_size[handle] = current_file_size[handle] }
  end

  def date_today     
    Time.now.strftime("%Y%m%d")
  end

  def handles
    @handles = `ls #{Settings.workdir}`.split("\n")
    new_handles = []
    @handles.each do |handle| 
      current_file(handle) if @current_file[handle].nil? 
      new_handles += [handle] if (`ls #{Settings.workdir + "/" + handle}`.split("\n").include?(date_today) || (current_file_size[handle] != 0))
    end
    @handles = new_handles
    return @handles
  end

  def files handle
    `ls -lt #{Settings.workdir + "/" + handle + "/" + date_today}`
  end

  def get_sizes handle
    size_list = files(handle).scan(/^[\-dlrwx]{10}\s\d\s\w+\s\w+\s+(\d+)/).flatten
    return size_list if size_list.empty?
    size_list.map{|size| size.to_i}
  end

  def current_file handle
    @current_file[handle] ||= ""
    file_list = `ls -1t #{Settings.workdir + "/" + handle + "/" + date_today}`.split("\n")
    return @current_file[handle] if file_list.empty?
    @current_file[handle] = date_today + "/" + file_list[0] if !(file_list[0].nil?)
    return @current_file[handle]
  end
  
  def current_file_size handle
    current_file(handle)
    return 0 if @current_file[handle] == ""
    return File.size(Settings.workdir + "/" + handle + "/" + @current_file[handle])
  end

  def num_files handle
    sizes = get_sizes(handle)
    return 0 if sizes.empty?
    sizes.length
  end

  def avg_size handle
    sizes = get_sizes(handle)
    return 0 if sizes.empty?
    tot_size = 0
    sizes.each{|size| tot_size += size}
    return (tot_size/sizes.length).to_i
  end
  
  def max_size handle
    sizes = get_sizes(handle)
    return 0 if sizes.empty?
    sizes.max
  end
  
  def min_size handle
    sizes = get_sizes(handle)
    return 0 if sizes.empty?
    sizes.min
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
      monitor.periodically do |metrics, iter, since|
        handles.each do |handle|
          sizes = get_sizes(handle)
          @last_size[handle] = current_file_size[handle] if @last_size[handle].nil?
          rate = size_rate(handle)
          metrics << ["scraper.#{hostname}.com_tw.#{handle.chomp.gsub(".","_")}.current_file_size", current_file_size(handle)]
          metrics << ["scraper.#{hostname}.com_tw.#{handle.chomp.gsub(".","_")}.size_rate", rate]
          metrics << ["scraper.#{hostname}.com_tw.#{handle.chomp.gsub(".","_")}.num_files", num_files(handle)] unless sizes.empty?
          metrics << ["scraper.#{hostname}.com_tw.#{handle.chomp.gsub(".","_")}.avg_file_size", avg_size(handle)] unless sizes.empty?
          metrics << ["scraper.#{hostname}.com_tw.#{handle.chomp.gsub(".","_")}.min_file_size", min_size(handle)] unless sizes.empty?
          metrics << ["scraper.#{hostname}.com_tw.#{handle.chomp.gsub(".","_")}.max_file_size", max_size(handle)] unless sizes.empty?
        end
      end
      sleep Settings.update_delay
    end
  end

end

Settings.die "Update delay is #{Settings.update_delay} seconds.  You probably want something larger." if Settings.update_delay < 60

FileMonitor.new.send_metrics
