#!/usr/bin/env ruby
# 结合zmap查找服务并提交到fofa
# sudo zmap -p 28017 -o - -N1000 | ./web_probe.rb 28017
# sudo zmap -p 9200 -o - -N1000 | ./web_probe.rb 9200
# sudo zmap -p 9200 -o - -w china_cidr.txt | ./web_probe.rb 80
# ./ip_china.rb > china_cidr.txt
#/usr/local/sbin/zmap
require 'net/http'
require 'uri'
require 'yaml'

root_path = File.expand_path(File.dirname(__FILE__))
require 'sidekiq'
require root_path+"/../../config/initializers/sidekiq.rb"
require root_path+"/../../app/workers/module/httpmodule.rb"
require root_path+"/../../app/workers/module/process_class.rb"

$port = 80
$port = ARGV[0].to_i if ARGV.size>0
puts "port is : #{$port}"

while (s = $stdin.gets)
  s.strip!
  Sidekiq::Client.enqueue(Processor, "#{s}:#{$port}")
end