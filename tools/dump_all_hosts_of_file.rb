#!/usr/bin/env ruby
# 获取文件中所有域名对应的子域名，每行一个子域名，
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
#puts "working dir: #{Dir.pwd}"

rails_env = ENV['RAILS_ENV'] || 'development'
thinking_config = YAML::load(File.open(@root_path+"/../config/thinking_sphinx.yml"))[rails_env]

config = YAML::load(File.open(@root_path+"/../config/database.yml"))[rails_env]
ActiveRecord::Base.establish_connection (config)

USE_THINKING_SPHINX=true
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

def query(query_info, max_id)
  hosts = []
  match_query =  SphinxProcessor.parse(query_info)

  options = {:match_mode => :extended, :index => 'subdomain_core',
             :with => {:id => max_id..9999999999},
             :sql => { :select => 'id,host'}, :per_page => 1000,
             :page => 1, :order => "id asc"}
  ThinkingSphinx.search(match_query, options).each{|r|
    hosts << r.host
    max_id = r.id
  }
  [hosts, max_id.to_i]
end

def query_all(query_info)
  maxid = 0
  while 1
    #puts $maxid
    hosts,maxid = query(query_info, maxid)
    unless hosts.size>0
      break
    end

    hosts.each{|h|
      yield h
    }
    maxid += 1
  end
end

require 'domainatrix'

def get_root_of_host(host)
  begin
    url = Domainatrix.parse(host)
    if url.domain && url.public_suffix
      return url.domain+'.'+url.public_suffix
    end
  rescue => e
    return nil
  end
end

File.open(ARGV[0], 'r').each{|line|
  host=get_root_of_host(line.strip)
  puts "==>"+host
  query_all("host=\"#{host}\""){|h|
    puts h
  }
}
