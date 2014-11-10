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

Dir.chdir @root_path+"/../"
puts "working dir: #{Dir.pwd}"

rails_env = ENV['RAILS_ENV'] || 'development'
thinking_config = YAML::load(File.open(@root_path+"/../config/thinking_sphinx.yml"))[rails_env]

config = YAML::load(File.open(@root_path+"/../config/database.yml"))[rails_env]
ActiveRecord::Base.establish_connection (config)

@m = WebDb.new(@root_path+"/../config/database.yml")

USE_THINKING_SPHINX=false
if USE_THINKING_SPHINX
  ThinkingSphinx::SphinxQL.functions!
  #ThinkingSphinx::Middlewares::DEFAULT.delete ThinkingSphinx::Middlewares::UTF8
  ThinkingSphinx::Configuration.instance.searchd.address = thinking_config['address']
  ThinkingSphinx::Configuration.instance.searchd.port = thinking_config['port']
else
  @mysql ||= Mysql2::Client.new(:host => thinking_config['address'],
                              :username => thinking_config['connection_options']['username'],
                               :password => thinking_config['connection_options']['password'],
                               :database => thinking_config['connection_options']['database'],
                               :port => thinking_config['mysql41'],
                               :encoding => 'utf8', :reconnect => true)
end

def build_info(query_array, col_name)
  results = {}
  query_array.each {|l|
    query_info = l[3]
    puts query_info
    match_query =  SphinxProcessor.parse(query_info)

    if USE_THINKING_SPHINX
      data = ThinkingSphinx.search(match_query, :match_mode => :extended)
      cnt = data.meta
    else
      match_sql = "select count(*) as cnt from subdomain_core where match('#{Mysql2::Client.escape(match_query)}')"
      puts match_sql
      cnt = @mysql.query(match_sql).first['cnt']
    end
    results[ l[0] ] = cnt
    puts "=> #{cnt}"
  }

  puts results.to_json
  sql = "insert into analysis_info (#{col_name}, writedate) values ('#{Mysql2::Client.escape(results.to_json)}', date(NOW())) ON DUPLICATE KEY UPDATE #{col_name}='#{Mysql2::Client.escape(results.to_json)}'"
  puts sql
  @m.mysql.query(sql)
end


build_info(get_cloudsec, 'cloudsec_info')
build_info(get_servers, 'server_info')
build_info(get_cms, 'cms_info')
