#!/usr/bin/env ruby
#失败任务太多时，web操作会导致超时，手动点需要上万次，必须用命令行工具
require 'yaml'
require 'pp'
@root_path = File.expand_path(File.dirname(__FILE__))

require "sidekiq"
require @root_path+"/../config/initializers/sidekiq.rb"
#require "sidekiq/api"
#require "sidekiq/failures/version"
#require "sidekiq/failures/sorted_entry"
#require "sidekiq/failures/failure_set"
#require "sidekiq/failures/middleware"
require "sidekiq/failures.rb"

$cnt = 0
module Sidekiq
  class SortedEntry

    def my_retry_failure
      Sidekiq.redis do |conn|
        results = conn.zrangebyscore(Sidekiq::Failures::LIST_KEY, score, score)
        conn.zremrangebyscore(Sidekiq::Failures::LIST_KEY, score, score)
        results.map do |message|
          msg = Sidekiq.load_json(message)
          Sidekiq::Client.push(msg)
          $cnt += 1
          puts $cnt if $cnt%100 == 0
        end
      end
    end
  end
end

#pp Sidekiq.methods.map{|var| puts var}
f = Sidekiq::Failures::FailureSet.new #retry_all_failures
while f.size > 0
  f.each(&:my_retry_failure)

end