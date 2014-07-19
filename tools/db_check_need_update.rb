#!/usr/bin/env ruby
#通过数据库的body分析，来提取所有url，通过api提交到fofa（超过90天才更新）
require 'mysql2'
#require 'thread/pool'
@root_path = File.expand_path(File.dirname(__FILE__))
require "resque"
require @root_path+"/../app/jobs/module/httpmodule.rb"
require @root_path+"/../app/jobs/module/webdb2_class.rb"
require @root_path+"/../app/jobs/module/process_class.rb"
require @root_path+"/../app/jobs/module/lrlink.rb"
include Lrlink
require 'script_detector'
require 'net/http'

def write_to_file(id)
  File.open(@root_path+"/update_id.txt", 'w') do |f|
    f.puts id
  end
end # Def end

@m = WebDb.new(@root_path+"/../config/database.yml")
@p = Processor.new(@m)
#@pool = Thread.pool(2)
@id=0

#load id from file
File.open(@root_path+"/update_id.txt", 'r') {|f|
  max_id = 0
  text = f.readline
  max_id = text.strip.to_i if text
  @id = max_id if max_id>@id
}

@max_id = @m.mysql.query("select max(id) as id from subdomain").first['id'].to_i

while true
  sql = "select id,title,host from subdomain where id>#{@id} and id<=#{@id+10000} and reverse_domain like 'nc.vog.%' order by id limit 100"
  r = @m.mysql.query(sql)
  puts sql
  if r.size>0
    hosts = []
    ids = []
    puts "===================="
    r.each {|h|
      hosts << h['host']
      ids << h['id']
      @id = h['id'].to_i
    }
    puts ids.join(',')
    puts "host count:"+hosts.size.to_s
    if hosts.size>0
      uri = URI('http://www.fofa.so/api/addhostp')
      res = Net::HTTP.post_form(uri, 'host' => hosts.join(','))
      #puts "id:"+ids.join(",")
      puts "response:"+res.body
    end
    write_to_file ids.max
    #curl_line = "curl http://www.fofa.so/api/addhost?host=#{hosts.uniq.join(',')} >/dev/null 2>&1"
    #puts curl_line
    #`#{curl_line}`
  elsif @id >= @max_id
    break
  else
    @id+=10000
  end

end
