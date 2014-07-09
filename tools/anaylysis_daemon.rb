#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'erb'
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/jobs/module/httpmodule.rb"
require @root_path+"/../app/jobs/module/webdb2_class.rb"

require 'thinking_sphinx'
ThinkingSphinx::SphinxQL.functions!
#ThinkingSphinx::Middlewares::DEFAULT.delete ThinkingSphinx::Middlewares::UTF8

require @root_path+"/../app/helpers/search_helper.rb"
include SearchHelper
require @root_path+"/../app/models/subdomain.rb"

Dir.chdir @root_path+"/../"
puts "working dir: #{Dir.pwd}"


config = YAML::load(File.open(@root_path+"/../config/thinking_sphinx.yml"))['development']
ThinkingSphinx::Configuration.instance.searchd.address = config['address']
ThinkingSphinx::Configuration.instance.searchd.port = config['port']

config = YAML::load(File.open(@root_path+"/../config/database.yml"))['development']
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

servers = [
    ['header="Microsoft-IIS" || header="X-Powered-By: WAF/2.0"', 'IIS'], #安全狗也是IIS
    ['header="nginx"', 'nginx'],
    ['header="Apache-Coyote"', 'Tomcat'],
    ['header="Apache" && header!="Apache-Coyote"', 'Apache'],
    ['header="Tengine"', 'TEngine'],
    ['header="IBM_HTTP_Server"', 'IBM_HTTP_Server'],
    #['header="Server: Oversee"'],
    ['header="Server: GSE"', 'GSE'],
    ['header="LiteSpeed"', 'LiteSpeed'],
    #['header="Server: BSM"'],
    ['header="Microsoft-HTTPAPI"', 'Microsoft-HTTPAPI'], #sqlserver2008
    #['header="Server: JDWS"'],
    #['header="Server: Youboy-WS"'],
    ['header="ngx_openresty"', 'ngx_openresty'],
    #['header="Server: PWS"'],
    #['header="Server: Tomcat"'], Server: Tomcat X-Powered-By: WAF/2.0 这个指纹是安全狗
    ['header="Server: Zeus"', 'Zeus'],
    ['header="Resin"', 'Resin'],
    ['header="Netscape-Enterprise"', 'Netscape-Enterprise'],
    ['header="Phusion"', 'Phusion'],
    ['header="webrick"', 'webrick'],
    ['header="Server: Jetty"', 'Jetty'],
    ['header="Sun-ONE-Web-Server"', 'Sun-ONE-Web-Server'],
    ['header="Oracle-Application-Server"', 'Oracle-Application-Server'],
    ['header="JBoss"', 'JBoss'],
]


build_info(get_cms, 'cms_info')
build_info(servers, 'server_info')
build_info(get_cloudsec, 'cloudsec_info')