#!/usr/bin/env ruby
#通过数据库的body分析，来提取所有url，通过api提交到fofa（超过90天才更新）
require 'mysql2'
#require 'thread/pool'
@root_path = File.expand_path(File.dirname(__FILE__))
require "resque"
require @root_path+"/../app/jobs/module/httpmodule.rb"
require @root_path+"/../app/jobs/module/webdb2_class.rb"
require @root_path+"/../app/jobs/module/process_class.rb"

def hostinfo_of_url(url)
  begin
    url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
    url = URI.encode(url) unless url.include? '%' #如果包含百分号%，说明已经编码过了
    uri = URI(url)
    rr = uri.host
    rr = rr+':'+uri.port.to_s if uri.port!=80 && uri.port!=443
    rr
  rescue => e
    nil
  end
end

def write_to_file(id)
  File.open(@root_path+"/id.txt", 'w') do |f|
    f.puts id
  end
end # Def end

@m = WebDb.new(@root_path+"/../config/database.yml")
@p = Processor.new(@m)
#@pool = Thread.pool(2)
@id=902660
while true
  sql = "select * from subdomain where id>#{@id} limit 1"
  r = @m.mysql.query(sql)
  if r.size>0
    r.each {|h|
      #@pool.process(h) { |h|
        puts "======#{h['id']} -> #{h['host']}======"
        arr = []
        h['body'].scan(/(http[s]?:\/\/.*?)[ \/\'\"\>]/).each{|x|
          arr << hostinfo_of_url(x[0]) if x[0].size>8 && x[0].include?('.')
        }

        arr.uniq.each{|a|
          puts a
          #@p.add_host_to_webdb h
          `curl http://www.fofa.so/api/addhost?host=#{a} >/dev/null 2>&1`
        }
      #}
      @id=h['id']
      write_to_file @id
    }

  else
    break
  end

end
