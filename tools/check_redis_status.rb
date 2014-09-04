#!/usr/bin/env ruby
# 打印redis的一些基本信息用于调试

require 'sidekiq'

@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../config/initializers/sidekiq.rb"

def getlen(redis, key, type)
  case type
    when 'string'
      1
    when 'hash'
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
  arr = []
  redis.keys("*").each{|key|
    type = redis.type(key)
    len = getlen(redis, key, type).to_i
    arr << {type: type, len: len, key: key} if len>1
  }
  arr.sort_by{|x| -x[:len].to_i}.each{|a|
    puts "#{a[:key]}: #{a[:type]}: #{a[:len]}"
  }

}