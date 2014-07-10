# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
#require 'thinking_sphinx/tasks' 

Webdbweb::Application.load_tasks

namespace :fofa do

  current_path = File.expand_path('../', __FILE__)

  desc "Show running workers"
  task :show_workers do
    system "ps -eo pid,command | grep resque | grep -v grep"
  end
  
  desc "Restart running workers"
  task :restart_workers => :environment do
    Rake::Task['fofa:stop_workers'].invoke
    Rake::Task['fofa:start_workers'].invoke
  end
  
  desc "Quit running workers"
  task :stop_workers => :environment do
    #pids = Array.new
    #Resque.workers.each do |worker|
    #  pids.concat(worker.worker_pids)
    #end
    #if pids.empty?
    #  puts "No workers to kill"
    #else
    #  syscmd = "kill -s QUIT #{pids.join(' ')}"
      syscmd = "ps aux | grep [r]esque | grep -v grep  | awk '{print $2}' | xargs -n 1 kill -s QUIT"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
    #end
  end
  
  desc "Start workers (1 process)"
  task :start_workers => :environment do
    run_worker("*", 1)
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart_unicorn  => :environment do
    syscmd = "cd #{current_path} ; kill -s USR2 `cat tmp/unicorn.pid`"
    puts "Running syscmd: #{syscmd}"
    system(syscmd)
  end

  desc "Start unicorn"
  task :start_unicorn  => :environment do
    syscmd = "cd #{current_path} ; unicorn_rails -E production --listen 3000 -D -c config/unicorn.rb" 
    puts "Running syscmd: #{syscmd}"
    system(syscmd)

    #environment "RAILS_ENV" => 'production'
    ENV['RAKE_ENV'] = production
    Rake::Task["assets:precompile"] #assets:precompile RAILS_ENV=production
  end

  desc "Stop unicorn"
  task :stop_unicorn  => :environment do
    syscmd ="cd #{current_path} ; kill -s QUIT `cat tmp/unicorn.pid`; rm -f tmp/unicorn.pid"
    puts "Running syscmd: #{syscmd}"
    system(syscmd)
  end

  desc "Start db link crawler"
  task :start_dblinkcrawler  => :environment do
    syscmd ="cd #{current_path} ; nohup ./tools/db_link_crawler.rb &"
    puts "Running syscmd: #{syscmd}"
    system(syscmd)
  end

  desc "start all"
  task :start_all do
    Rake::Task["fofa:start_unicorn"].invoke
    Rake::Task["fofa:start_workers"].invoke
  end

  desc "stop all"
  task :stop_all do
    Rake::Task["fofa:stop_unicorn"].invoke
    Rake::Task["fofa:stop_workers"].invoke
  end

  desc "restart all"
  task :restart_all do
    Rake::Task["fofa:restart_workers"].invoke
    Rake::Task["fofa:restart_unicorn"].invoke
  end

end

# Start a worker with proper env vars and output redirection
def run_worker(queue, count = 1)
  puts "Starting #{count} worker(s) with QUEUE: #{queue}"
  ops = {:pgroup => true, :err => [(Rails.root + "log/workers_error.log").to_s, "a"],
                          :out => [(Rails.root + "log/workers.log").to_s, "a"]}
  env_vars = {"QUEUE" => queue.to_s}
  count.times {
    ## Using Kernel.spawn and Process.detach because regular system() call would
    ## cause the processes to quit when capistrano finishes
    pid = spawn(env_vars, "rake resque:work", ops)
    Process.detach(pid)
  }
end