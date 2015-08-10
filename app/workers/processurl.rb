require File.join(FOFA_ROOT_PATH, 'workers', 'lrlink.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'httpmodule.rb')

include Lrlink
include Sidekiq::Worker
include HttpModule

ERROR_BLACK_IP = -6

def process_url(host, domain, subdomain, addlinkhosts=true, userid=0)
  #泛域名解析这里会超时，尽可能往下放
  ENV['FOFA_IP_SETTED'] ||= '0'
  ENV['FOFA_INVALID_IP'] ||= ''
  if ENV['FOFA_IP_SETTED']=='0'
    ENV['FOFA_IP_SETTED'] = '1'
    puts "check invalid_ip" if ENV['FOFA_DEBUG']
    begin
      ENV['FOFA_INVALID_IP'] = get_ip_of_host_resolv('nevercouldexists.qq.com')
    rescue Resolv::ResolvError => e
      #puts "Unknown Exception of : #{host}\n error:#{$!} at:#{$@}\nerror : #{e}"
      ENV['FOFA_INVALID_IP'] = ''
    end
    puts "invalid_ip is : #{ENV['FOFA_INVALID_IP']}" if ENV['FOFA_DEBUG']
  end
  only_host = host_of_url(host)
  ip = get_ip_of_host(only_host)
  return ERROR_HOST_DNS if !ip || (ENV['FOFA_INVALID_IP'].size>0 && ip==ENV['FOFA_INVALID_IP'])
  return ERROR_BLACK_IP if (is_bullshit_ip?(ip)  || FofaDB.redis_black_ip?(ip))

  #获取http信息
  http_info = get_http(host)
  if http_info && ! http_info[:error]
    #return ERROR_BLACK_IP if is_bullshit_ip?(http_info[:ip])

    if addlinkhosts
      utf8html = http_info[:utf8html]
      get_linkes(utf8html).each {|h|
        Sidekiq.redis do |conn|
          if conn.zincrby('checkurl_hosts', 1, host).to_i == 1
            Sidekiq::Client.enqueue(CheckUrlWorker, h)
          end
        end
      }
    end

    #提交下一个队列
    mini_info={host:host, domain:domain, subdomain:subdomain, ip:http_info[:ip], title:http_info[:title], header:http_info[:header], utf8html:http_info[:utf8html]}
    return yield(host, domain, subdomain, mini_info, addlinkhosts, userid) if block_given?
    Sidekiq::Client.enqueue(UpdateIndexWorker, host, domain, subdomain, mini_info, addlinkhosts, userid)
    return 0
  elsif http_info
    Sidekiq::Client.enqueue(HttpErrorWorker, host, domain, subdomain, http_info)
    return -7
  end
end

class ProcessUrlWorker

  sidekiq_options :queue => :process_url, :retry => 3, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    #todo 丢到国外的服务器
    #Sidekiq::Client.enqueue(GFWWorker, msg['args'])
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def initialize
  end

  def perform(host, domain, subdomain, addlinkhosts=true, userid=0)
    puts "[#{self.class}] process_url of #{url}" if ENV['FOFA_DEBUG']
    ret = process_url(host, domain, subdomain, addlinkhosts, userid)
    puts "[#{self.class}] process_url return #{ret}" if ENV['FOFA_DEBUG']
  end


end