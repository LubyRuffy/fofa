require File.join(FOFA_ROOT_PATH, 'workers', 'lrlink.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'fofadb.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'checkurl.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'processurl.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'updateindex.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'subdomain.rb')


class RealtimeprocessWorker
  def initialize
  end

  sidekiq_options :queue => :realtime_process, :retry => 3, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours


  def perform(url, force=false, addlinkhosts=true, userid=0)
    checkurl(url, force, addlinkhosts, userid){ |host, domain, subdomain, addlinkhosts, userid|
      process_url(host, domain, subdomain, addlinkhosts, userid){|host, domain, subdomain, http_info, addlinkhosts, userid|
        http_info = JSON.parse(http_info.to_json)
        update_index(host, domain, subdomain, http_info, addlinkhosts, userid)
      }
    }
  end

end
