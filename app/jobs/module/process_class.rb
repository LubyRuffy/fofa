#!/usr/bin/env ruby
require 'domainatrix'

class Processor
  include HttpModule
  
  @queue = "process_url"
  @webdb = nil
  def initialize(webdb)
    @webdb = webdb
  end

  def get_domain_info_by_host(host)
    url = Domainatrix.parse(host)
    if url.domain && url.public_suffix
      return url
    end
    nil
  end


  #最上层函数，添加host到数据库
  def add_host_to_webdb(host, force=false)

    return -1 if host.include?('/') || host =~ /\d+\.\d+\.\d+\.\d/

      domain_info = get_domain_info_by_host(host)
    #pp domain_info
    return -2 if !domain_info
    domain = domain_info.domain+'.'+domain_info.public_suffix

    #检查是否需要更新
    if !force && !@webdb.need_update_host(host)
      #puts "#{host} no need to update"
      return 1 
    end

    #更新检查时间
    @webdb.update_subdomain_if_exists(host)

    #获取http信息
    http_info = get_http(host)
    if http_info && ! http_info[:error]
      #puts host
      #pp http_info
      #更新ip
      @webdb.insert_ip_to_ipaddr(http_info[:ip])
      #更新根域名表
      @webdb.insert_domain_to_rootdomain(domain)
      #更新子域名表
      @webdb.update_host_to_subdomain(host, domain, domain_info.subdomain, http_info)
      return 0
    else
      @webdb.insert_host_to_error_table(host, "#{Socket.gethostname} : http failed!")
      return -3
    end
  end

end


