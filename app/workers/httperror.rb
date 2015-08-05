require File.join(FOFA_ROOT_PATH, 'workers', 'lrlink.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'fofadb.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'subdomain.rb')

class HttpErrorWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :http_error, :retry => 3, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def initialize
  end

  def perform(host, domain, subdomain, http_info)
    http_error(host, domain, subdomain, http_info)
  end

  def http_error(host, domain, subdomain, http_info)
    FofaDB.redis_inc_failed_host(host)
    #@webdb.insert_host_to_error_table(host, "#{Socket.gethostname} : http failed! #{http_info[:errstring]}") if http_info[:write_error]
  end
end