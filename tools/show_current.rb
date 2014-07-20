#!/usr/bin/env ruby
#通过数据库的body分析，来提取所有url，通过api提交到fofa（超过90天才更新）
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/jobs/module/webdb2_class.rb"
require @root_path+"/../app/jobs/module/lrlink.rb"
include Lrlink

@m = WebDb.new(@root_path+"/../config/database.yml")
@last_array = []

@bid=0
if ARGV.size>0
  @max_id = @m.queryer.query("select max(id) as id from subdomain").first['id'].to_i
  while true
    puts "process id : -#{@bid}"
    sql = %Q{SELECT
      count(*) AS cnt,
                  ip,
                  host,
                  subdomain,
                  domain,
                  title
      FROM
        subdomain
      WHERE
        id < #{@max_id} - #{@bid}
        AND id > #{@max_id} - #{@bid+100000}
        AND subdomain != 'www'
        AND subdomain != ''
      GROUP BY ip
      HAVING cnt > 100
      ORDER BY cnt DESC}
    res= @m.queryer.query(sql)
    break unless res.size>0
    res.each{|r|
      unless is_bullshit_host?(r["host"]) || is_bullshit_ip?(r["ip"])
        if @last_array.select{|lr| r["ip"] == lr["ip"]}.empty?
          printf("[%s] %-8s%-24s%-20s%-30s%-30s\n", Time.now, r["cnt"], r["ip"], r["subdomain"], r["domain"], r["title"])
        end
      end
    }

    @bid+=100000
  end
else
  while true
    @current_array= []
    res= @m.mysql.query("select count(*) as cnt,ip,host,subdomain,domain,title from subdomain where id>(select max(id) from subdomain)-100000 and subdomain!='www' and subdomain!='' GROUP BY ip having cnt>100 order by cnt desc ")
    res.each{|r|
      @current_array << r
    }

    #puts "="*80
    @current_array.each{|r|
      unless is_bullshit_host?(r["host"]) || is_bullshit_ip?(r["ip"])
        if @last_array.select{|lr| r["ip"] == lr["ip"]}.empty?
          printf("[%s] %-8s%-24s%-20s%-30s%-30s\n", Time.now, r["cnt"], r["ip"], r["subdomain"], r["domain"], r["title"])
        end
      end
    }
    @last_array = @current_array

    sleep 5
  end
end