class LabController < ApplicationController
  def ips
    @domain = params['domain']
    @ips = Subdomain.connection.execute(%Q{
select INET_NTOA(INET_ATON(ip) & 0xFFFFFF00) as net,GROUP_CONCAT(hosts) as hosts,GROUP_CONCAT(ip) as ips,count(*) as cnt from(
	select ip,GROUP_CONCAT(host) as hosts from (select ip, host from subdomain
	where reverse_domain=reverse(#{Subdomain.connection.quote(@domain)}) limit 10000) t group by ip
)t group by net order by cnt desc,net asc
      })

  end
end
