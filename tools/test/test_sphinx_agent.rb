#!/usr/bin/env ruby
require 'yaml'
require 'benchmark'
require 'mysql2'

@root_path = File.expand_path(File.dirname(__FILE__))
Dir.chdir @root_path

rails_env = ENV['RAILS_ENV'] || 'development'
config = YAML::load(File.open(@root_path+"/../../config/database.yml"))[rails_env]
ips = YAML::load(File.open(@root_path+"/../../config/ips.yml"))['sphinx_servers']

class String
  def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end


ips.split(',').each_with_index{|h,i|
  puts "========SphinxQL server : #{h}========"
  result = Benchmark.measure do
    mysql = Mysql2::Client.new(:host => h, :username => config['username'],
                               :port => 9306, :secure_auth => config['secure_auth'],
                               :encoding => 'utf8', :reconnect => true)

    mysql.query("select max(lastupdatetime) as lasttime,count(*) as cnt from idx1p#{i} limit 1").each do |row|
      puts "#{row['cnt']}, #{Time.at(row['lasttime'].to_i)}, "
    end
  end
  #puts "===Mysql time : "+result.to_s
}

=begin
rs = []
ips.split(',').each_with_index{|h,i|
  result = Benchmark.measure do
    @info = `./test.py -h #{h} -p 9312 -i idx1p#{i} test -l 1`.string_between_markers('times in ',' documents')
  end
  rs << "------> #{h} => #{@info} : cost time :"+result.to_s
}

rs.each{|r| puts r}
=end