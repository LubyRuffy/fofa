#!/usr/bin/env ruby
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/workers/module/process_class.rb"
require @root_path+"/../app/helpers/search_helper.rb"
require 'active_record'

#require @root_path+"/../config/initializers/sidekiq.rb"
#require 'awesome_print'

rails_env = ENV['RAILS_ENV'] || 'development'
config = YAML::load(File.open(@root_path+"/../config/database.yml"))[rails_env]
ActiveRecord::Base.establish_connection (config)
require @root_path+"/../app/models/rule.rb"
require @root_path+"/../app/models/subdomain.rb"

include SearchHelper
include HttpModule

def get_http_info_from_db_or_net(url)
  http_info = nil
  #try to get from db
  http_info ||= Subdomain.where(:host=>host_of_url(url)).take
  #if not then get from net
  http_info ||= get_http(url)
  http_info[:body] = http_info[:utf8html] if http_info[:utf8html] && !http_info[:body]
  http_info
end

def check_info(app, http_info)
  AppProcessor.parse(app.rule, http_info)
end

def check_app(url)
  http_info = get_http_info_from_db_or_net(url)
  Rule.all.each{ |app|
    return app.product if check_info(app, http_info)
  }
  nil
end

if ARGV.size>0
  app = check_app(ARGV[0])
  if app
    puts app
  else
    puts "unknown app"
  end
else
  puts "Usage: $0 <host> "
end
