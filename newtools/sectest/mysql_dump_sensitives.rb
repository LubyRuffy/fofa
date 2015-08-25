#!/usr/bin/env ruby
# 配合zmap使用
require 'mysql2'
require 'yaml'
require 'benchmark'
require 'awesome_print'


$sensitive_fields = %w|email password pass pwd|

def sensitive? (name)
  #puts name
  name = name.downcase
  $sensitive_fields.each { |s|
    if name.include? s
      return true
    end
  }
  false
end

def audit_mysql(h, password, username='root', port=3306)
  puts "========mysql server : #{h}========"
  result = Benchmark.measure do
    mysql = Mysql2::Client.new(:host => h, :username => username,
                               :password => password,
                               :port => port, :secure_auth => false,
                               :encoding => 'utf8', :reconnect => true, :connect_timeou => 5)
    arr = []
    if mysql.query("select version()").first['version()'][0].to_i < 5
      arr = []
      puts "[INFO] version less than 5, brute force..."
      mysql.query("show databases").map { |h| h['Database'] }.select { |d| d!='mysql' }.each { |d|
        #puts " - "+d
        mysql.query("use #{d}")
        mysql.query("show tables").map { |h| h["Tables_in_#{d}"] }.each { |t|
          sensitve_field = mysql.query("SHOW COLUMNS FROM #{t}").map { |f| f['Field'] }.select { |f| sensitive?(f) }
          if sensitve_field.size>0
            cnt = mysql.query("select count(*) as cnt from #{t}").first['cnt']
            arr << [d, t, cnt, sensitve_field] if cnt>1000
          end
        }
      }
    else
      query = %Q{SELECT column_name,table_name,table_schema FROM INFORMATION_SCHEMA.COLUMNS WHERE (#{$sensitive_fields.map { |s| "column_name like '%#{s}%'" }.join(' or ')}) and table_schema!='mysql'}
      #puts query
      mysql.query(query).each do |row|
        begin
        table_schema = row['table_schema']
        table_name = row['table_name']
        cnt = mysql.query("select count(*) as cnt from #{table_schema}.#{table_name}").first['cnt']
        arr << [table_schema, table_name, cnt] if cnt>1000
        rescue Mysql2::Error => e
          #'denied to'
        end
      end
    end
    ap arr.sort_by { |a| -a[2].to_i }
  end
  puts "===Mysql time : "+result.to_s
rescue =>e
  puts e
end

h=ARGV[0]
password=ARGV[1]
username='root'
username=ARGV[2] if ARGV[2]
port=3306
port=ARGV[3].to_i if ARGV[3]
if h
  audit_mysql(h, password, username, p)
else
  while line = gets
    h,username,username,port = line.strip.split('\t')
    port ||= 3306
    password = '' if password=='[]'
    audit_mysql(h, password,username,port)
  end
end

