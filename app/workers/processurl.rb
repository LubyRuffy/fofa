require File.join(FOFA_ROOT_PATH, 'workers', 'lrlink.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'httpmodule.rb')

class ProcessUrlWorker
  include Lrlink
  include Sidekiq::Worker
  include HttpModule

  ERROR_BLACK_IP = -6

  sidekiq_options :queue => :process_url, :retry => 3, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    #todo 丢到国外的服务器
    #Sidekiq::Client.enqueue(GFWWorker, msg['args'])
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def initialize
  end

  def perform(host, domain, subdomain, addlinkhosts=true, userid=0)
    process_url(host, domain, subdomain, addlinkhosts, userid)
  end

  def process_url(host, domain, subdomain, addlinkhosts=true, userid=0)
    #获取http信息
    http_info = get_http(host)
    if http_info && ! http_info[:error]
      return ERROR_BLACK_IP if is_bullshit_ip?(http_info[:ip])

      #提交下一个队列
      mini_info={host:host, domain:domain, subdomain:subdomain, ip:http_info[:ip], title:http_info[:title], header:http_info[:header], utf8html:http_info[:utf8html]}
      Sidekiq::Client.enqueue(UpdateIndexWorker, host, domain, subdomain, mini_info, addlinkhosts, userid)

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

      return 0
    elsif http_info
      Sidekiq::Client.enqueue(HttpErrorWorker, host, domain, subdomain, http_info)
      return -7
    end
  end
end