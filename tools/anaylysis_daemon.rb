#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'erb'
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/workers/module/httpmodule.rb"
require @root_path+"/../app/workers/module/webdb2_class.rb"

require 'thinking_sphinx'
ThinkingSphinx::SphinxQL.functions!
#ThinkingSphinx::Middlewares::DEFAULT.delete ThinkingSphinx::Middlewares::UTF8

require @root_path+"/../app/helpers/search_helper.rb"
include SearchHelper
require @root_path+"/../app/models/subdomain.rb"

Dir.chdir @root_path+"/../"
puts "working dir: #{Dir.pwd}"

rails_env = ENV['RAILS_ENV'] || 'development'
config = YAML::load(File.open(@root_path+"/../config/thinking_sphinx.yml"))[rails_env]
ThinkingSphinx::Configuration.instance.searchd.address = config['address']
ThinkingSphinx::Configuration.instance.searchd.port = config['port']

config = YAML::load(File.open(@root_path+"/../config/database.yml"))[rails_env]
ActiveRecord::Base.establish_connection (config)

@m = WebDb.new(@root_path+"/../config/database.yml")

def build_info(query_array, col_name)
  results = {}
  query_array.each {|l|
    query_info = l[3]
    print query_info
    cnt = ThinkingSphinx.search(SphinxProcessor.parse(query_info), :match_mode => :extended).meta['total_found']
    results[ l[0] ] = cnt
    puts "=>"+cnt
  }

  puts results.to_json
  sql = "insert into analysis_info (#{col_name}, writedate) values ('#{Mysql2::Client.escape(results.to_json)}', date(NOW())) ON DUPLICATE KEY UPDATE #{col_name}='#{Mysql2::Client.escape(results.to_json)}'"
  puts sql
  @m.mysql.query(sql)
end


build_info(get_cloudsec, 'cloudsec_info')
build_info(get_servers, 'server_info')
build_info(get_cms, 'cms_info')
