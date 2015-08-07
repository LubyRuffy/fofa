#!/usr/bin/env ruby
require 'yaml'
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../config/initializers/sidekiq.rb"
require 'active_record'
require 'elasticsearch'
require 'elasticsearch/model'
require @root_path+"/../config/initializers/elasticsearch.rb"
require 'celluloid'
require 'sidekiq/fetch'
require @root_path+"/../app/workers/updateindex.rb"
require @root_path+"/../app/workers/checkurl.rb"
require @root_path+"/../app/workers/processurl.rb"
include Lrlink
require 'thread/pool'

$debug = false
if ARGV.size>0
  $debug = true
end

$thread_count = $debug ? 1:30
pool = Thread.pool($thread_count)
$bulks = []

def bulk_submit
  puts "bulk update index task: #{$bulks.map{|h| h['host'] }}"
  v = Subdomain.es_bulk_insert($bulks)
  if $debug
    puts "es_bulk_insert return: #{v}"
  end
  $bulks.clear
end

fetch = Sidekiq::BasicFetch.new(:queues => [
                                        'update_index',
                                        'check_url',
                                        'process_url'
                                    ])
while 1
  work = fetch.retrieve_work
  if work
    msg = Sidekiq.load_json(work.message)
    args = msg['args']
    if msg['class'] == 'UpdateIndexWorker'
      if $debug
        puts "update index of url: #{args[0]}"
      end
      update_index(*args){|http_info|
        $bulks << http_info
        false
      }
      bulk_submit if $bulks.size>=10
    elsif msg['class'] == 'CheckUrlWorker'

      if $debug
        puts "check url task: #{args[0]}"
      else
        print '.'
      end

      pool.process(args){|args|
        v = checkurl(*args)
        if $debug
          puts "return value: #{v}"
        end
      }
    elsif msg['class'] == 'ProcessUrlWorker'
      if $debug
        puts "process url: #{args[0]}"
      else
        print '.'
      end

      pool.process(args){|args|
        v = process_url(*args)
        if $debug
          puts "process_url return value: #{v}"
        end
      }
    end
  else
    bulk_submit if $bulks.size>0 #获取不到新任务就把队列的先提交
    print '.'
    sleep 1
  end
end