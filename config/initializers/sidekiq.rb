rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

config = YAML.load_file(rails_root + '/config/database.yml')[rails_env]['redis']
redis_url = "redis://#{config['host']}:#{config['port']}/#{config['db']}"
Sidekiq.configure_server do |cfg|
  cfg.redis = { :url => redis_url, :namespace => "#{config['namespace']}" }
end

Sidekiq.configure_client do |cfg|
  cfg.redis = { :url => redis_url, :namespace => "#{config['namespace']}" }
end