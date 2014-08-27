rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

config = YAML.load_file(rails_root + '/config/database.yml')[rails_env]['redis']
redis_url = "redis://#{config['host']}:#{config['port']}/#{config['db']}"

# Redis config
#Redis.current = ConnectionPool.new(size: (Sidekiq.server? ? 10 : 2), timeout: 5) do
#  Redis::Namespace.new(config['namespace'], :redis => Redis.new(:url => redis_url))
#end

=begin
require 'sidekiq'
require 'sidekiq/fetch'

module Sidekiq
  class DynamicFetch < Sidekiq::BasicFetch
    include Sidekiq::Util

    def initialize(options)
      super
    end

    def retrieve_work
      queues = @strictly_ordered_queues ? @unique_queues.dup : @queues.shuffle.uniq
      queues.each{|q|
        w = Sidekiq.redis { |conn| conn.rpop(q) }
        if w
          return UnitOfWork.new(q,w)
        end
      }
      nil
    end
  end
end

Sidekiq.options[:fetch] = Sidekiq::DynamicFetch
=end

Sidekiq.configure_server do |cfg|
  cfg.redis = { :url => redis_url, :namespace => "#{config['namespace']}", :size => 2 }
  cfg.failures_max_count = false
end

Sidekiq.configure_client do |cfg|
  cfg.redis = { :url => redis_url, :namespace => "#{config['namespace']}", :size => 2 }
end


