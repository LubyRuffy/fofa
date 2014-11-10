#!/usr/bin/env ruby
#提取rootdomain，更新whois
require 'yaml'
require 'json'
require 'erb'
require 'active_record'

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
config = YAML::load(File.open(@root_path+"/../config/database.yml"))[rails_env]
ActiveRecord::Base.establish_connection (config)

  @mysql ||= Mysql2::Client.new(:host => thinking_config['address'],
                                :username => thinking_config['connection_options']['username'],
                                :password => thinking_config['connection_options']['password'],
                                :database => thinking_config['connection_options']['database'],
                                :port => thinking_config['mysql41'],
                                :encoding => 'utf8', :reconnect => true)

def query(query_info, max_id)
  headers = []
  match_query =  SphinxProcessor.parse(query_info)

  options = {:match_mode => :extended, :index => 'subdomain_core',
             :with => {:id => max_id..9999999999},
             :sql => { :select => 'id,header,host'}, :per_page => 1000,
             :page => 1, :order => "id asc"}
  ThinkingSphinx.search(match_query, options).each{|r|
    headers << r.header
    max_id = r.id
  }
  [headers, max_id.to_i]
end

$maxid = 0
$keys = []
$known_keys = %w|Last-Modified Date Content-Length Connection Cache-Control Content-Location Last-Modified Etag Transfer-Encoding Content-Encoding Vary Expires Pragma Content-Language Location|
while 1
  headers,$maxid = query('host=".gov.cn"', $maxid)
  unless headers.size>0
    break
  end

  headers.each{|header|
    header.split(/[\r\n]/).each{|l|
      if l.include? ':'
        k,v = l.split(':')
        unless $keys.include?(k) || $known_keys.include?(k)
          $keys << k
          puts l
        end
      end
    }
  }

  puts "-----", $maxid
end


