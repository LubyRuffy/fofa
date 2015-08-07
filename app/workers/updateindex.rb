require File.join(FOFA_ROOT_PATH, 'workers', 'lrlink.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'fofadb.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'subdomain.rb')

def update_index(host, domain, subdomain, http_info, addlinkhosts, userid=0)
  #puts http_info
  FofaDB.changecount(host,domain,http_info['ip']) unless Subdomain.es_exists?(host) #更新计数，用于加黑
  need_insert = true
  need_insert = yield(http_info) if block_given?
  if need_insert
    Subdomain.es_insert(host,domain,subdomain,http_info) #更新索引
  end
  FofaDB.add_user_points(userid, 'host', 1) if userid>0
end

class UpdateIndexWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :update_index, :retry => 3, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def initialize
  end

  def perform(host, domain, subdomain, http_info, addlinkhosts, userid=0)
    puts "[#{self.class}] update_index of #{url}" if ENV['FOFA_DEBUG']
    ret = update_index(host, domain, subdomain, http_info, addlinkhosts, userid)
    puts "[#{self.class}] update_index return #{ret}" if ENV['FOFA_DEBUG']
  end
end