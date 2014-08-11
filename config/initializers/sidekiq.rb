rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

config = YAML.load_file(rails_root + '/config/database.yml')[rails_env]['redis']
redis_url = "redis://#{config['host']}:#{config['port']}/#{config['db']}"

# Redis config
#Redis.current = ConnectionPool.new(size: (Sidekiq.server? ? 10 : 2), timeout: 5) do
#  Redis::Namespace.new(config['namespace'], :redis => Redis.new(:url => redis_url))
#end

Sidekiq.configure_server do |cfg|
  cfg.redis = { :url => redis_url, :namespace => "#{config['namespace']}", :size => 10 }
  cfg.failures_max_count = false
end

Sidekiq.configure_client do |cfg|
  cfg.redis = { :url => redis_url, :namespace => "#{config['namespace']}", :size => 2 }
end
