#!/usr/bin/env ruby
#删除数据库中作恶的ip对应的host（只保留根域名或www）
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/workers/module/webdb2_class.rb"
#Mysql2::Client.default_query_options[:connect_flags] |= Mysql2::Client::MULTI_STATEMENTS

require "resque"
rails_env = 'production'
resque_config = YAML.load_file(@root_path+"/../config/database.yml")
Resque.redis = "#{resque_config[rails_env]['redis']['host']}:#{resque_config[rails_env]['redis']['port']}"
@m = WebDb.new(@root_path+"/../config/database.yml")

def process_redis
  @process_cnt = 0
  while true
    @queryed = false
    @m.mysql.query('begin')
    (0..999).each{|i|
      sql = Resque.redis.redis.lpop("fofa:sql")
      if sql
        @queryed = true
        @process_cnt += 1
        @m.mysql.query(sql)
      else
        break
      end
    }
    @m.mysql.query('commit')
    print "processed:#{@process_cnt} all:#{ Resque.redis.redis.llen("fofa:sql") }\r"
    break unless @queryed
  end
end

process_redis