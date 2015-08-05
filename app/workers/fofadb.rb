require 'mysql2'
require 'redis'

=begin
Mysql和Redis操作类

redis中可以进行的全局配置：
＊ fofa:cfg:black_domain_threshold 根域名最大支持多少个host（阈值，默认200），超出后自动加黑
＊ fofa:cfg:black_ips_threshold 单个ip最大支持多少个host处理（阈值，默认200），超出后自动加黑
=end
class FofaDB

  Sidekiq.redis{|redis|
    @redis ||= redis
    @black_domain_threshold=@redis.get('fofa:cfg:black_domain_threshold') || 200
    @black_ips_threshold=@redis.get('fofa:cfg:black_ips_threshold') || 200
  }

  class << self



    def redis_black_domain?(domain)
      return true unless domain
      @redis.sismember('fofa:black_domains', domain)
    end

    def redis_black_ip?(ip)
      return true unless ip
      ip = ip.split('.')[0..2].join('.')
      @redis.sismember('fofa:black_ips', ip)
    end

    def redis_has_host?(host)
      return true unless host
      @redis.sismember('fofa:hosts', host)
    end

    def redis_black_host?(host)
      return true unless host
      @redis.sismember('fofa:black_hosts', host)
    end

    def redis_inc_failed_host(host)
      @redis.sadd('fofa:black_hosts', host) if @redis.zincrby('fofa:failedhosts',1,host)>10
    end

    def redis
      @redis
    end

    def changecount(host,domain,ip)
      redis_add_host(host)
      redis_inc_rootdomain(domain)
      redis_inc_ip(ip)
    end

    def add_user_points(userid, category, point)

    end

    private


    def redis_inc_rootdomain(domain)
      #超出阈值加黑
      if @redis.zincrby('fofa:rootdomains',1,domain)>@black_domain_threshold
        @redis.sadd('fofa:black_domains', domain)
      end
    end

    def redis_add_host(host)
      @redis.sadd('fofa:hosts', host)
    end

    def redis_inc_ip(ip)
      ip = ip.split('.')[0..2].join('.')
      if @redis.zincrby('fofa:ips',1,ip)>@black_ips_threshold
        @redis.sadd('fofa:black_ips', ip)
      end
    end
  end
  
end