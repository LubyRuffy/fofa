#!/usr/bin/env ruby
@root_path = File.expand_path(File.dirname(__FILE__))
puts @root_path
require "resque"
require 'resque/failure/redis'
require @root_path+"/../app/jobs/module/httpmodule.rb"
require @root_path+"/../app/jobs/module/webdb2_class.rb"
require @root_path+"/../app/jobs/module/process_class.rb"
require 'yaml'

root_path = File.expand_path(File.dirname(__FILE__))
rails_env = 'production'
resque_config = YAML.load_file(root_path+"/../config/database.yml")
Resque.redis = "#{resque_config[rails_env]['redis']['host']}:#{resque_config[rails_env]['redis']['port']}"

def need_del? (failure)
  true if failure[:error].include?('Duplicate entry')
  false
end

i=0
delc = 0

while job = Resque::Failure.all(0)
  #p job
  if job["error"].include?('Duplicate entry') || job["error"].include?('nil:NilClass')
    delc += 1
  else
    puts job["error"] if job["error"].include?('unknown encoding name')
    Resque::Failure::requeue(0)
  end
  Resque::Failure::Redis.remove(0)
  i+=1


  if i%1000==0
    puts "#{delc}/#{i} deleted"
  end

end

