require File.join(FOFA_ROOT_PATH, 'workers', 'lrlink.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'fofadb.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'processurl.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'subdomain.rb')
require 'date'

ERROR_INVALID_HOST = -1
ERROR_INVALID_IP = -2
ERROR_INVALID_DOMAIN = -3
ERROR_BLACK_HOST = -4
ERROR_BLACK_DOMAIN = -5
ERROR_BLACK_IP = -6
ERROR_HOST_DNS = -7
HOST_NONEED_UPDATE = -8

def need_update_host(host)
  need_update = false
  exists_host = false

  hostdoc = Subdomain.es_get(host)
  if hostdoc
    exists_host = true

    diff_time = (Time.now - Time.parse(hostdoc['_source']['lastchecktime'])).to_i
    if  (diff_time/86400)>90
      need_update = true
    end
  else
    need_update = true
  end
  [need_update, exists_host]
end

#最上层函数，添加host到数据库
def checkurl(host, force=false, addlinkhosts=true, userid=0)
  host = hostinfo_of_url(host.downcase)
  return ERROR_INVALID_HOST unless host
  return ERROR_INVALID_HOST if host.include?('/') && !host.include?('https://')
  return ERROR_BLACK_HOST if FofaDB.redis_black_host?(host)
  only_host = host_of_url(host)

  domain_is_ip = false
  if only_host =~ /\d+\.\d+\.\d+\.\d/
    if ip_dec?(only_host) #0000314.00000014.0306.000000375
      return ERROR_INVALID_IP
    end
    domain = host
    domain_is_ip = true
  elsif ip_dec?(only_host) #这种类型的ip：0x0079.0x000000000000000028.0x0083.00257
    return ERROR_INVALID_IP
  else
    domain_info = get_domain_info_by_host(host)
    #pp domain_info
    return ERROR_INVALID_DOMAIN if !domain_info
    domain = domain_info.domain+'.'+domain_info.public_suffix
    return ERROR_BLACK_DOMAIN if FofaDB.redis_black_domain?(domain)
  end

  #泛域名解析这里会超时，尽可能往下放
  ip = get_ip_of_host(only_host)
  return ERROR_HOST_DNS unless ip
  return ERROR_BLACK_IP if is_bullshit_ip?(ip)  || FofaDB.redis_black_ip?(ip)

  #检查是否需要更新
  need_update,exists_host = need_update_host(host)
  unless (need_update || force)
    #logger.debug "[#{self.class}] #{host} no need to update"
    return HOST_NONEED_UPDATE
  end

  #更新检查时间
  FofaES.update_checktime_of_host(host) if exists_host

  #return 1 if @@just_for_test #测试桩，在rspec中用到，并不实际提交到Sidekiq

  #提交下一个队列
  Sidekiq::Client.enqueue(ProcessUrlWorker, host, domain, domain_is_ip ? '':domain_info.subdomain, addlinkhosts, userid)
end

class CheckUrlWorker
  include Lrlink
  include Sidekiq::Worker

  sidekiq_options :queue => :check_url, :retry => 3, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def initialize
    @@just_for_test = false
  end

  def perform(url, force=false, addlinkhosts=true, userid=0)
    logger.debug "[#{self.class}] checkurl of #{url}"
    ret = checkurl(url, force, addlinkhosts, userid)
    logger.debug "[#{self.class}] checkurl return #{ret}"
    ret
  end

end
