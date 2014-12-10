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

  #Uitask.new(WebDb.new(root_path+"/../../../config/database.yml")).perform(1, "alldomains", 'qzone.com', 1000)
  Uitask.new(WebDb.new(root_path+"/../../../config/database.yml")).perform(1, "gethosts", 'qzone.com', 1000)
  #Uitask.new(WebDb.new(root_path+"/../../../config/database.yml")).perform(1, "alldomainsfrom", 'baidu.com', 1000)
end
