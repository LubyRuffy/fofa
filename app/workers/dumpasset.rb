require File.join(FOFA_ROOT_PATH, 'workers', 'lrlink.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'fofadb.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'uitask.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'subdomain.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'asset_domain.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'asset_ip.rb')
#require File.join(FOFA_ROOT_PATH, 'models', 'asset_host.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'modules', 'emaildigger.rb')

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

def import_emails(target_id, domain, options={})
  domain = domain[1..-1] if domain[0] == '@'

  options ||= {search:1, github:1, bruteforce:1}

  @emails = Sgk.get_emails(domain, 10000)
  @emails += EmailDigger.new(domain).importAll(options)

  @emails.uniq.each{|email|
      begin
        AssetPerson.find_or_create_by(target_id: target_id, email: email, name: email, domain: domain)
        add_target_msg(target_id, email)
      rescue => e
        puts e
      end
  }
end

def import_domain(target_id, domain)
  @ips = Subdomain.get_ips_of_domain(domain, 10000)
  @ips.each do |net|
    ipnet,hosts,ips,netipcnt = net
    hosts.split(',').each{|h|
      begin
        AssetHost.find_or_create_by(target_id: target_id, host: h, domain: domain)
        add_target_msg(target_id, h)
      rescue => e
        puts e
      end

    }
    ips.split(',').each{|ip|
      begin
        AssetIp.find_or_create_by(target_id: target_id, ip: ip, domain: domain, ipnet: ipnet)
        add_target_msg(target_id, ip)
      rescue => e
        puts e
      end
    }
  end

  #email
  import_emails(target_id, email)
end

def dump_asset(target_id, domain)
  #Sidekiq.redis{|redis|
  #  key = target_redis_key(target_id)
  #  redis.expire(key, 2*60*60) #2小时
  #}
  unless Target.exists?(target_id)
    return
  end
  add_target_msg(target_id, 'dump worker started...')

  #主域名
  AssetDomain.find_or_create_by(target_id: target_id, domain: domain)
  import_domain(target_id, domain)

  #兄弟域名
  getalldomains(domain, 1000){|d|
    AssetDomain.find_or_create_by(target_id: target_id, domain: d)
    add_target_msg(target_id, d)
    import_domain(target_id, d)
  }


  add_target_msg(target_id, '<<<finished>>>')
end

class ImportDomainAssetWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 3, :backtrace => true

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform(target_id, domain)
    import_domain(target_id, domain)
  end

end

class ImportEmailAssetWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 3, :backtrace => true

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform(target_id, domain, options=nil)
    import_emails(target_id, domain, options)
  end

end


class DumpassetWorker
  include Sidekiq::Worker

  sidekiq_options :retry => 3, :backtrace => true

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform(target_id, target_domain)
    dump_asset(target_id, target_domain)
  end

end

