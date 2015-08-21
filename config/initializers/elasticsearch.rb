
unless ARGV[0] && ARGV[0].include?('fofa:') #rake任务时就不用初始化了
  rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
  rails_env = ENV['RAILS_ENV'] || 'development'
  config = YAML.load_file(rails_root + '/config/database.yml')[rails_env]['elasticsearch']
  elasticsearch_url = "#{config['host']}:#{config['port']}"

  Elasticsearch::Model.client = Elasticsearch::Client.new url:elasticsearch_url, log: (rails_env!='production' && !Sidekiq.server?)
  #Elasticsearch::Model::Response::Response.__send__ :include, Elasticsearch::Model::Response::Pagination::WillPaginate
end
