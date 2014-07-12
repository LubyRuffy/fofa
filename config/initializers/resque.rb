rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/database.yml')
Resque.redis = "#{resque_config[rails_env]['redis']['host']}:#{resque_config[rails_env]['redis']['port']}"
Resque.logger = Logger.new(File.join(Rails.root, 'log', 'resque.log'), 'a')