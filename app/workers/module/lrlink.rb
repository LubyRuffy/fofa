# encoding: utf-8
require 'domainatrix'
require 'uri'

module Lrlink
  def get_domain_info_by_host(host)
    url = Domainatrix.parse(host)
    if url.domain && url.public_suffix
      return url
    end
    nil
  end

  def host_port_of_url(url)
    begin
      url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
      url = URI.encode(url) unless url.include? '%' #如果包含百分号%，说明已经编码过了
      uri = URI(url)
      [uri.host, uri.port]
    rescue => e
      nil
    end
  end

  def host_of_url(url)
    begin
      url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
      url = URI.encode(url) unless url.include? '%' #如果包含百分号%，说明已经编码过了
      uri = URI(url)
      uri.host
    rescue => e
      nil
    end
  end

  def hostinfo_of_url(url)
    begin
      url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
      url = URI.encode(url) unless url.include? '%' #如果包含百分号%，说明已经编码过了
      uri = URI(url)
      rr = uri.host
      rr = rr+':'+uri.port.to_s if uri.port!=80 && uri.port!=443
      rr = 'https://'+rr if uri.scheme == 'https'
      rr
    rescue => e
      nil
    end
  end

  def get_linkes(html)
    arr = []
    if html
      html.scan(/(http[s]?:\/\/.*?)[ \/\'\"\>]/).each{|x|
        if x[0].size>8 && x[0].include?('.')
          hostinfo = hostinfo_of_url(x[0].downcase)
          arr << hostinfo if hostinfo && hostinfo!='www.' && hostinfo!='ssl.'
        end
      }
    end
    arr.uniq
  end

  def get_ip_of_host(host)
    require 'socket'
    ip = Socket.getaddrinfo(host, nil)
    return nil if !ip || !ip[0] || !ip[0][2]
    ip[0][2]
  rescue => e
    nil
  end

  def is_bullshit_ip?(ip)
    $ips = %q{0.0.0.0
127.0.0.}
    return true if !ip
    $ips.each_line{|bip|
      return true if bip && bip.size>4 && ip.start_with?(bip.strip)
    }
    false
  end

end