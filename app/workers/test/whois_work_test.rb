#!/usr/bin/env ruby


if __FILE__==$0
  root_path = File.expand_path(File.dirname(__FILE__))
  puts root_path
  require root_path+"/../module/httpmodule.rb"
  require root_path+"/../module/webdb2_class.rb"
  require root_path+"/../module/process_class.rb"

  class Uitask
    def addmsg(jobid,msg)
      puts msg
    end
  end

  #include HttpModule

  #puts get_http('www.fofa.so')
  #Uitask.new(WebDb.new(root_path+"/../../../config/database.yml")).perform 1, 'alldomains', 'sohu.com'
  WhoisTask.new(WebDb.new(root_path+"/../../../config/database.yml")).perform 'canalfuxion.tv',true
end
