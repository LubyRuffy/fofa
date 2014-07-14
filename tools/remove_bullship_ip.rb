#!/usr/bin/env ruby
#删除数据库中作恶的ip对应的host（只保留根域名或www）
require 'mysql2'
#require 'thread/pool'
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/jobs/module/webdb2_class.rb"
require @root_path+"/../app/jobs/module/lrlink.rb"
include Lrlink



@m = WebDb.new(@root_path+"/../config/database.yml")
@bid_file = @root_path+"/bid.txt"
@id=0
@did=0

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

while true
  sql = "select id,ip,subdomain from subdomain where id>#{@id} limit 5000"
  r = @m.mysql.query(sql)
  if r.size>0
    r.each {|h|
      @id=h['id']
      if h['ip'] && is_bullshit_ip?(h['ip']) && h['subdomain'].size>4
        sql = "delete from subdomain where id=#{@id}"
        #puts sql
        @m.mysql.query(sql)
        @did +=1
        print "#{h['id']} : [deleted: #{@did}]\r"
      end
    }
    print "#{@id} : [deleted: #{@did}]\r"
    write_to_file @id
  else
    break
  end

end
