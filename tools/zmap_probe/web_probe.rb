#!/usr/bin/env ruby
# 结合zmap查找服务并提交到fofa
# sudo zmap -p 28017 -o - -N1000 | ./web_probe.rb 28017
# sudo zmap -p 9200 -o - -N1000 | ./web_probe.rb 9200
# sudo zmap -p 9200 -o - -w china_cidr.txt | ./web_probe.rb 80
# ./ip_china.rb > china_cidr.txt
#/usr/local/sbin/zmap
#require 'thread/pool'
require 'net/http'
require 'uri'
require 'yaml'
#require 'celluloid/autostart'

root_path = File.expand_path(File.dirname(__FILE__))
require "resque"
require root_path+"/../../app/jobs/module/httpmodule.rb"
require root_path+"/../../app/jobs/module/process_class.rb"
cfgfile = "#{root_path}/../../config/database.yml"
rails_env = ENV['RAILS_ENV'] || 'development'
g_config = YAML::load(File.open(cfgfile))
config = g_config[rails_env]['redis']
Resque.redis = "#{config['host']}:#{config['port']}"

class HostSubmitor
  #include Celluloid
  attr_accessor :hosts

  def initialize()
    @hosts = []
  end

  def addhost(host)
    @hosts << host
    if @hosts.size == 200
      submit
      @hosts = []
    end
  end

  def submit
    if @hosts.size>0
      @uri ||= URI('http://www.fofa.so/api/addhostp')
      res = Net::HTTP.post_form(@uri, 'host' => @hosts.join(','))
      res = Net::HTTP.post_form(@uri, 'host' => @hosts.join(',')) if res.code != 200
      res = Net::HTTP.post_form(@uri, 'host' => @hosts.join(',')) if res.code != 200
      puts "response:"+res.body
    end
  end
end

$port = 80
$port = ARGV[0].to_i if ARGV.size>0
puts "port is : #{$port}"
#STDOUT.sync = true
#STDIN.sync = true
#@pool = Thread.pool(100)
#@hs = HostSubmitor.new

while (s = $stdin.gets)
  s.strip!
  Resque.enqueue(Processor, "#{s}:#{$port}")

  #@hs.addhost "#{s}:#{$port}"
=begin
  @pool.process(s) {|s|
    begin
      Net::HTTP.start(s, $port) do |http|
        http.open_timeout = 10  # xxx: 間違い
        http.read_timeout = 10

        response = http.head('/')
        if response.code && response.code.to_i<1000
          #addurl = "curl http://fofa.so/api/addhost?host=#{s}:#{$port}"
          #puts addurl
          #`#{addurl}`
          @hs.addhost "#{s}:#{$port}"
        end
      end
      rescue=>e
    end
  }
=end
end

#@hs.submit #把剩下的全部提交了

#@pool.join
#@pool.shutdown
