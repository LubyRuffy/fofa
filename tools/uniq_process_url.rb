#!/usr/bin/env ruby
# redis 任务队列去重
require 'resque'
require 'yaml'

root_path = File.expand_path(File.dirname(__FILE__))
rails_env = 'production'
resque_config = YAML.load_file(root_path+"/../config/database.yml")
Resque.redis = "#{resque_config[rails_env]['redis']['host']}:#{resque_config[rails_env]['redis']['port']}"

key = 'queue:process_url'
if Resque.redis.exists(key)

  members = Resque.redis.lrange(key, 0, -1)
  duplicate_members = members.group_by { |e| e }.select { |k, v| v.size > 1 }.map(&:first)

  if duplicate_members.count > 0

    puts "#{key}: has #{duplicate_members.count} duplicates"

    duplicate_members.each do |duplicate_member|
      puts "Removing #{duplicate_member}"
      Resque.redis.lrem(key, -1, duplicate_member)
    end

  end

end