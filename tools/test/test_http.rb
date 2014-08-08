#!/usr/bin/env ruby
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../../app/workers/module/process_class.rb"

include HttpModule

http_info = get_http(ARGV[0])
puts http_info[:title]
