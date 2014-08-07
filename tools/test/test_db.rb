#!/usr/bin/env ruby

root_path = File.expand_path(File.dirname(__FILE__))
require root_path+"/../../app/workers/module/webdb2_class.rb"
require 'thread/pool'

p = Thread.pool(50)
100.times{|i|
  p.process(i){|i|
    db = WebDb.new(root_path+"/../../config/database.yml")
    j=0
    breadnum = rand(1000)
    loop {
      puts "#{i} : #{j}"
      db.mysql_exists_host("#{i}.#{j}")
      j += 1
      throw "error" if breadnum == j
      sleep 0.01
    }
  }
}
p.shutdown