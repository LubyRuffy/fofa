#!/usr/bin/env ruby
#通过数据库的body分析，来提取所有url，通过api提交到fofa（超过90天才更新）

unless `ps aux | grep '#{File.basename(__FILE__)}' | grep -v grep | grep -v #{Process.pid} | grep -v '.bash_profile'`.empty?
  puts 'already anothor running, now exit...'
  exit(-1)
end

require 'mysql2'
#require 'thread/pool'
@root_path = File.expand_path(File.dirname(__FILE__))
require 'sidekiq'
require @root_path+"/../config/initializers/sidekiq.rb"
require @root_path+"/../app/workers/module/process_class.rb"
include Lrlink
require 'net/http'

MODE='sidekiq' #fofa_api 或者 sidekiq

def write_to_file(id)
  File.open(@root_path+"/id.txt", 'w') do |f|
    f.puts id
  end
end # Def end

@m = WebDb.new(@root_path+"/../config/database.yml")
@p = Processor.new(@m)
#@pool = Thread.pool(2)
@id=902660

#load id from file
File.open(@root_path+"/id.txt", 'r') {|f|
  max_id = 0
  text = f.readline
  max_id = text.strip.to_i if text
  @id = max_id if max_id>@id
}

STDOUT.sync = true
while true
  sql = "select * from subdomain where id>#{@id} limit 10"
  r = @m.mysql.query(sql)
  if r.size>0
    hosts = []
    ids = []
    puts "===================="
    print "id: "
    r.each {|h|
      #@pool.process(h) { |h|
        #puts "======#{h['id']} -> #{h['host']}======"
        print h['id'].to_s+" "
        arr = get_linkes(h['body'])
        arr.each{|a|
          hosts << a
        }
      #}
      @id=h['id']
      ids << h['id']

    }

    hosts.uniq!
    puts ""
    puts "host count:"+hosts.size.to_s
    if hosts.size>0
      case MODE
        when 'fofa_api'
          uri = URI('http://www.fofa.so/api/addhostp')
          res = Net::HTTP.post_form(uri, 'host' => hosts.join(','))
          #puts "id:"+ids.join(",")
          puts "response:"+res.body
        else
          hosts.each{|h|
            Sidekiq::Client.enqueue(Processor, h)
          }
      end


    end
    write_to_file ids.max
    #curl_line = "curl http://www.fofa.so/api/addhost?host=#{hosts.uniq.join(',')} >/dev/null 2>&1"
    #puts curl_line
    #`#{curl_line}`
  else
    break
  end

end
