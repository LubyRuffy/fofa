#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'erb'
require 'active_record'
require 'thinking_sphinx'

@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/workers/module/httpmodule.rb"
require @root_path+"/../app/workers/module/webdb2_class.rb"

require @root_path+"/../app/helpers/search_helper.rb"
include SearchHelper
require @root_path+"/../app/models/subdomain.rb"
require @root_path+"/../app/models/rule.rb"
require @root_path+"/../app/models/charts.rb"

Dir.chdir @root_path+"/../"
puts "working dir: #{Dir.pwd}"

rails_env = ENV['RAILS_ENV'] || 'development'
thinking_config = YAML::load(File.open(@root_path+"/../config/thinking_sphinx.yml"))[rails_env]

config = YAML::load(File.open(@root_path+"/../config/database.yml"))[rails_env]
ActiveRecord::Base.establish_connection (config)

@mysql ||= Mysql2::Client.new(:host => thinking_config['address'],
                              :username => thinking_config['connection_options']['username'],
                               :password => thinking_config['connection_options']['password'],
                               :database => thinking_config['connection_options']['database'],
                               :port => thinking_config['mysql41'],
                               :encoding => 'utf8', :reconnect => true)
puts thinking_config
def query(query_info, minid=0, limit=1000)
    match_query =  SphinxProcessor.parse(query_info)
    maxid = 0
    match_sql = "select id from subdomain_core where match('#{Mysql2::Client.escape(match_query)}') and id>#{minid} order by id asc limit #{limit};"
    puts match_sql
    @mysql.query(match_sql).each{|r|
      puts r
      maxid = [r['id'].to_i,maxid].max
    }
    maxid
end

maxid = 0
while 1
  maxid = query('title="test"', maxid)
  break unless maxid>0
  puts "======"+maxid.to_s
  maxid += 1
end