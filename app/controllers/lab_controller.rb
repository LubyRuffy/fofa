class LabController < ApplicationController
  def ips
    @domain = params['domain']
    if @domain
      key = 'domain_net:'+@domain.downcase
      @ips = Sidekiq.redis{|redis| redis.get(key) }
      if @ips
        @ips = JSON.parse(@ips)
      else
        @ips = Subdomain.connection.execute(%Q{
            select INET_NTOA(INET_ATON(ip) & 0xFFFFFF00) as net,GROUP_CONCAT(hosts) as hosts,GROUP_CONCAT(ip) as ips,count(*) as cnt from(
              select ip,GROUP_CONCAT(host) as hosts from (select ip, host from subdomain
              where reverse_domain=reverse(#{Subdomain.connection.quote(@domain)}) limit 10000) t group by ip
            )t group by net order by cnt desc,net asc
          })
        Sidekiq.redis{|redis|
          redis.set(key, @ips.to_json)
          redis.expire(key, 60*60*24)
        }
      end
    end
  end
end
