#!/usr/bin/env ruby
if __FILE__==$0
  root_path = File.expand_path(File.dirname(__FILE__))
  puts root_path
  require root_path+"/../module/httpmodule.rb"
  require root_path+"/../module/webdb2_class.rb"
  require root_path+"/../module/process_class.rb"

  #include HttpModule

  #puts get_http('www.fofa.so')
  Processor.new(WebDb.new(root_path+"/../../../config/database.yml")).add_host_to_webdb 'webscan.360.cn', true, false, 3
end
