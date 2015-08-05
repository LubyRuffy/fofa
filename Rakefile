# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'turnout/rake_tasks'
require File.expand_path('../config/application', __FILE__)

Fofa::Application.load_tasks

namespace :fofa do

  current_path = File.expand_path('../', __FILE__)

  desc "Show running workers"
  task :show_workers do
    ps = `ps -eo pid,command | grep sidekiq | grep -v grep`
    puts ps
  end
  
  desc "Restart running workers"
  task :restart_workers => :environment do
    Rake::Task['fofa:stop_workers'].invoke
    Rake::Task['fofa:start_workers'].invoke
  end
  
  desc "Quit running workers"
  task :stop_workers => :environment do
      syscmd = "ps aux | grep sidekiq | grep -v grep  | awk '{print $2}' | xargs -n 1 kill -s QUIT"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
    #end
  end

  desc "Quit running workers force"
  task :stop_workers_force => :environment do
    syscmd = "ps aux | grep sidekiq | grep -v grep  | awk '{print $2}' | xargs -n 1 kill -9"
    puts "Running syscmd: #{syscmd}"
    system(syscmd)
    #end
  end
  
  desc "Start workers (threads can set by WCNT environment)"
  task :start_workers => :environment do
    `rm -f #{Rails.root}/log/*.log`
    puts "Starting #{ENV['WCNT']} worker(s)"
    concurrency = ''
    concurrency = '-c '+ENV['WCNT'] if ENV['WCNT']
    ops = {:pgroup => true, :err => [(Rails.root + "log/workers_error.log").to_s, "a"],
           :out => [(Rails.root + "log/workers.log").to_s, "a"]}
    env_vars = {"RAILS_ENV"=>"production"}
    cmd = "bundle exec sidekiq -L #{Rails.root}/log/workers.log -C #{Rails.root}/config/sidekiq.yml #{concurrency} -d"
    puts cmd
    pid = spawn(env_vars, cmd, ops)
    Process.detach(pid)
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart_unicorn  => :environment do
    syscmd = "cd #{current_path} ; kill -s USR2 `cat tmp/unicorn.pid`"
    puts "Running syscmd: #{syscmd}"
    system(syscmd)

    Rake::Task["fofa:precompile"]
  end

  desc "Start unicorn"
  task :start_unicorn  => :environment do
    syscmd = "cd #{current_path} ; unicorn_rails -E production --listen 3000 -D -c config/unicorn.rb" 
    puts "Running syscmd: #{syscmd}"
    system(syscmd)

    Rake::Task["fofa:precompile"]
  end

  desc "Precompile assets"
  task :precompile => :environment do
    ENV['RAKE_ENV'] = 'production'
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

  desc 'Runs Sidekiq as a rake task'
  task :debug_sidekiq => :environment do
    require 'sidekiq'
    require 'sidekiq/cli'
    begin
      cli = Sidekiq::CLI.instance
      cli.parse
      cli.run
    rescue => e
      raise e if $DEBUG
      STDERR.puts e.message
      STDERR.puts e.backtrace.join("\n")
      exit 1
    end
  end

  desc "add point cron task"
  task :pointcron => :environment do
    Pointcrons.all.each{|p|
      User.find(p.user_id).add_points(p.point, category: p.category) if p.user_id.to_i>0
      #处理完成就删除
      p.destroy
    }
  end

end