#!/usr/bin/env ruby
@root_path = File.expand_path(File.dirname(__FILE__))
puts @root_path
require "resque"
require @root_path+"/../app/workers/module/httpmodule.rb"
require @root_path+"/../app/workers/module/webdb2_class.rb"
require @root_path+"/../app/workers/module/process_class.rb"
require 'yaml'

root_path = File.expand_path(File.dirname(__FILE__))
rails_env = 'production'
resque_config = YAML.load_file(root_path+"/../config/database.yml")
Resque.redis = "#{resque_config[rails_env]['redis']['host']}:#{resque_config[rails_env]['redis']['port']}"

def need_del? (url)
  bullshit = %w|www.170yx.com www.dchzz.com www.dhhrss.gov.cn www.aifengshui.com www.517ln.com www.gzsnsdb.com www.opai.com.cn www.667e.com|
  bullshit.each{|h|
    return true if url.include? h
  }

  hosts = url.split(',')
  len = hosts.inject(0){|memo,s|memo+s.length}
  sl = len/hosts.size
  return true if hosts.size>20 && sl>15
  false
end

i=0
delc = 0
#while job = Resque::Job.reserve(:process_url)
while job = Resque::Job.reserve(:quick_process_host)
  #job = Resque::Job.reserve(:realtime_process_list)
  url = job.payload['args'].to_s
  del = need_del? url
  job.recreate unless del
  delc +=1 if del
  if i%1000==0
    puts "#{delc} deleted"
    delc = 0
  end
  i+=1
end

