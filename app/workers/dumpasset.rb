require File.join(FOFA_ROOT_PATH, 'workers', 'lrlink.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'fofadb.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'uitask.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'subdomain.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'asset_domain.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'asset_ip.rb')
#require File.join(FOFA_ROOT_PATH, 'models', 'asset_host.rb')

def target_redis_key(target_id)
  "target_asset_dump:#{target_id}"
end

def add_target_msg(target_id,msg)
  Sidekiq.redis{|redis|
    key = target_redis_key(target_id)
    redis.rpush(key, msg)
    redis.expire(key, 60) #10秒超时
  }
end

def dump_asset(target_id, domain)
  #Sidekiq.redis{|redis|
  #  key = target_redis_key(target_id)
  #  redis.expire(key, 2*60*60) #2小时
  #}
  add_target_msg(target_id, 'dump worker started...')
  AssetDomain.find_or_create_by(target_id: target_id, domain: domain)

  getalldomains(domain, 1000){|d|
    AssetDomain.find_or_create_by(target_id: target_id, domain: d)
    add_target_msg(target_id, d)
  }
  @ips = Subdomain.get_ips_of_domain(domain, 10000)
  @ips.each do |net|
    ipnet,hosts,ips,netipcnt = net
    hosts.split(',').each{|h|
      AssetHost.find_or_create_by(target_id: target_id, host: h)
      add_target_msg(target_id, h)
    }
    ips.split(',').each{|ip|
      AssetIp.find_or_create_by(target_id: target_id, ip: ip)
      add_target_msg(target_id, ip)
    }
  end

  add_target_msg(target_id, '<<<finished>>>')
end

class DumpassetWorker

  sidekiq_options :retry => 3, :backtrace => true, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform(target_id, target_domain)
    dump_asset(target_id, target_domain)
  end

end
