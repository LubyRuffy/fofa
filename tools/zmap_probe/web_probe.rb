#!/usr/bin/env ruby
# 结合zmap查找服务并提交到fofa
# sudo zmap -p 28017 -o - -N1000 | ./web_probe.rb 28017
# sudo zmap -p 9200 -o - -N1000 | ./web_probe.rb 9200
# sudo zmap -p 9200 -o - -w china_cidr.txt | ./web_probe.rb 80
# ./ip_china.rb > china_cidr.txt
#/usr/local/sbin/zmap
require 'thread/pool'
require 'net/http'
require 'uri'

$port = 80
$port = ARGV[0].to_i if ARGV.size>0
puts "port is : #{$port}"
STDOUT.sync = true
STDIN.sync = true
@pool = Thread.pool(100)
while (s = $stdin.gets)
  s.strip!
  @pool.process(s) {|s|
    begin
      Net::HTTP.start(s, $port) do |http|
        http.open_timeout = 10  # xxx: 間違い
        http.read_timeout = 10

        response = http.head('/')
        if response.code && response.code.to_i<1000
          addurl = "curl http://fofa.so/api/addhost?host=#{s}:#{$port}"
          puts addurl
          `#{addurl}`
        end
      end
      rescue=>e
    end
  }
end

@pool.shutdown
