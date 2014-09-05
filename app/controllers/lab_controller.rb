class LabController < ApplicationController
  def ips
    @domain = params['domain']
    @ips = Subdomain.connection.execute(%Q{
        select INET_NTOA(INET_ATON(ip) & 0xFFFFFF00) as net,GROUP_CONCAT(hosts) as hosts,GROUP_CONCAT(ip) as ips,count(*) as cnt from(
        select ip,GROUP_CONCAT(host) as hosts from subdomain
        where reverse_domain=reverse(#{Subdomain.connection.quote(@domain)}) group by ip
        )t group by net order by cnt desc
      })

  end
end
