#!/usr/bin/env ruby
# 打印redis的一些基本信息用于调试

require 'sidekiq'

@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../config/initializers/sidekiq.rb"

def getlen(redis, key, type)
  case type
    when 'string'
      1
    when 'set'
      redis.scard(key)
    when 'list'
      redis.llen(key)
    when 'zset'
      redis.zcard(key)
    else
      'unknown'
  end
end

Sidekiq.redis {|redis|
  redis.keys("*").each{|key|
    type = redis.type(key)
    len = getlen(redis, key, type)
    puts "#{key}: #{type}: #{len}"
  }
}