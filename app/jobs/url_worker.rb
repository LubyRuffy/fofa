#!/usr/bin/env ruby
root_path = File.expand_path(File.dirname(__FILE__))
require "resque"
require root_path+"/module/httpmodule.rb"
require root_path+"/module/webdb2_class.rb"
require root_path+"/module/process_class.rb"

if __FILE__==$0
  puts Processor.perform(ARGV[0])
end