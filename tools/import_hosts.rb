#!/usr/bin/env ruby
#文件导入host，每行一个
@root_path = File.expand_path(File.dirname(__FILE__))
require 'sidekiq'
require @root_path+"/../config/initializers/sidekiq.rb"
include Lrlink

@lino = 0
File.open(ARGV[0], 'r') do |f|
  f.each{|l|
    Sidekiq::Client.enqueue(Processor, l.strip)
    @lino+=1
    print "#{@lino}\r" if @lino%1000==0
  }
end
