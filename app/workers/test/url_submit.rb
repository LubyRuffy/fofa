#!/usr/bin/env ruby
if __FILE__==$0
  root_path = File.expand_path(File.dirname(__FILE__))
  require 'sidekiq'
  require 'pp'
  require root_path+"/../url_worker.rb"

  pp Sidekiq::Client.enqueue(Processor, ARGV[0])
end

