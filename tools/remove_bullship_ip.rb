#!/usr/bin/env ruby
#删除数据库中作恶的ip对应的host（只保留根域名或www）
require 'mysql2'
require 'thread/pool'
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/jobs/module/webdb2_class.rb"
require @root_path+"/../app/jobs/module/lrlink.rb"
include Lrlink

require "resque"
rails_env = 'production'
resque_config = YAML.load_file(@root_path+"/../config/database.yml")
Resque.redis = "#{resque_config[rails_env]['redis']['host']}:#{resque_config[rails_env]['redis']['port']}"


@m = WebDb.new(@root_path+"/../config/database.yml")
@bid_file = @root_path+"/bid.txt"
@id=30000000
@did=0
@process_cnt=0
@process_redis_cnt = 0

#load id from file
if File.exist?(@bid_file)
  File.open(@bid_file, 'r') {|f|
    max_id = 0
    text = f.readline
    max_id = text.strip.to_i if text
    @id = max_id if max_id>@id
  }
end

def write_to_file(id)
  File.open(@bid_file, 'w') do |f|
    f.puts id
  end
end # Def end

def send_to_redis
  while true
    sql = "select id,ip,subdomain,title from subdomain where id<=#{@id} order by id desc limit 5000"
    r = @m.mysql.query(sql)
    if r.size>0
      r.each {|h|
        @id= [h['id'],@id].min
        @process_cnt+=1
        if (h['ip'] && is_bullshit_ip?(h['ip']) && (h['subdomain'].size>0 && h['subdomain']!='www')) || (is_bullshit_title?(h['title'], h['subdomain']))
          sql = "delete from subdomain where id=#{@id}"
          #puts sql
          @m.mysql.query(sql)
          #Resque.redis.redis.rpush("fofa:sql", sql)
          @did +=1
          print "#{@id} : [deleted: #{@did}] [processed:#{@process_cnt}] [redis_processed:#{@process_redis_cnt}]\r"
        end
      }
      print "#{@id} : [deleted: #{@did}] [processed:#{@process_cnt}] [redis_processed:#{@process_redis_cnt}]\r"
      write_to_file @id
    else
      break
    end
  end
end

def process_redis
  while true
    @queryed = false
    @m.mysql.query('begin')
    (0..99).each{|i|
      sql = Resque.redis.redis.lpop("fofa:sql")
      if sql
        @queryed = true
        @process_redis_cnt += 1
        @m.mysql.query(sql)
      else
        break
      end
    }
    @m.mysql.query('commit')
    print "#{@id} : [deleted: #{@did}] [processed:#{@process_cnt}] [redis_processed:#{@process_redis_cnt}]\r"
    break unless @queryed
  end
end

#thr = Thread.new { send_to_redis }
#process_redis
send_to_redis