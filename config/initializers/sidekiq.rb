require 'yaml'
require 'sidekiq'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

config = YAML.load_file(rails_root + '/config/database.yml')[rails_env]['redis']
redis_url = "redis://#{config['host']}:#{config['port']}/#{config['db']}"
if config['password']
  redis_url = "redis://:#{config['password']}@#{config['host']}:#{config['port']}/#{config['db']}"
end
Sidekiq::Logging.logger.level = Logger::ERROR

Sidekiq.configure_server do |cfg|
  cfg.redis = { :url => redis_url, :namespace => "#{config['namespace']}", :size => 2, :pool_timeout => 15}
end

Sidekiq.configure_client do |cfg|
  cfg.redis = { :url => redis_url, :namespace => "#{config['namespace']}", :size => 2, :pool_timeout => 15 }
end


FOFA_ROOT_PATH = File.expand_path('../../../app/',  __FILE__)
#puts FOFA_ROOT_PATH