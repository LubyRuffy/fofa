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
thinking_config = YAML::load(File.open(@root_path+"/../config/thinking_sphinx.yml"))['development']

config = YAML::load(File.open(@root_path+"/../config/database.yml"))[rails_env]
ActiveRecord::Base.establish_connection (config)

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

def build_info(r)

    puts r.id
    query_info = r.rule
    puts query_info
    match_query =  SphinxProcessor.parse(query_info)

    cnt = 0
    if USE_THINKING_SPHINX
      data = ThinkingSphinx.search(match_query, :match_mode => :extended)
      cnt = data.meta
    else
      match_sql = "select count(*) as cnt from subdomain_core where match('#{Mysql2::Client.escape(match_query)}')"
      puts match_sql
      res = @mysql.query(match_sql).first
      cnt = res['cnt'] if res
    end
    puts "=> #{cnt}"
    Charts.where(writedate: Time.now.strftime("%Y-%m-%d"), rule_id:r.id).first_or_initialize.update_attributes!(value:cnt, writedate: Time.now.strftime("%Y-%m-%d"), rule_id:r.id)

end


Rule.all.each{|r|
  build_info(r)
}
