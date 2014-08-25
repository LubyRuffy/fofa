#!/usr/bin/env ruby
require 'mysql2'
require 'yaml'
require 'benchmark'

@root_path = File.expand_path(File.dirname(__FILE__))
Dir.chdir @root_path

rails_env = ENV['RAILS_ENV'] || 'development'
config = YAML::load(File.open(@root_path+"/../config/database.yml"))[rails_env]
ips = YAML::load(File.open(@root_path+"/../config/ips.yml"))['mysql_servers']

ips.split(',').each_with_index{|h,i|
  puts "========mysql server : #{h}========"
  result = Benchmark.measure do
    mysql = Mysql2::Client.new(:host => h, :username => config['username'],
                                   :password => config['password'],
                                   :port => config['port'], :secure_auth => config['secure_auth'],
                                   :encoding => 'utf8', :reconnect => true)

    mysql.query("show processlist").each do |row|
      printf("%-8s%-8s%-25s%-10s %-30s %s\n",row['Id'],row['Time'],row['Host'],row['Command'],row['State'],row['Info']) unless row['Command']=='Sleep'
    end
  end
  puts "===Mysql time : "+result.to_s
}
