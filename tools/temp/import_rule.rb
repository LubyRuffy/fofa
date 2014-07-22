#!/usr/bin/env ruby
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../../app/helpers/search_helper.rb"
require @root_path+"/../../app/jobs/module/webdb2_class.rb"

include SearchHelper

@m = WebDb.new(@root_path+"/../config/database.yml")
get_cms.each{|c|
  name,date,url,rule=c[0],c[1],c[2],c[3]
  puts name,date,url,rule
  sql = "insert into rule(product, producturl, rule, created_at, user_id) values(#{name})"
}