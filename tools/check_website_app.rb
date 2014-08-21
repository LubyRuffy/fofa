#!/usr/bin/env ruby
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/workers/module/process_class.rb"
require @root_path+"/../app/helpers/search_helper.rb"
include SearchHelper

require 'active_record'

#require @root_path+"/../config/initializers/sidekiq.rb"
#require 'awesome_print'

rails_env = ENV['RAILS_ENV'] || 'development'
config = YAML::load(File.open(@root_path+"/../config/database.yml"))[rails_env]
ActiveRecord::Base.establish_connection (config)
require @root_path+"/../app/models/rule.rb"
require @root_path+"/../app/models/subdomain.rb"
require @root_path+"/../app/workers/module/process_class.rb"

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
