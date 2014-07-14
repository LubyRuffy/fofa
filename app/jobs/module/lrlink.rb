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
      rr
    rescue => e
      nil
    end
  end

  def get_linkes(html)
    arr = []
    html.scan(/(http[s]?:\/\/.*?)[ \/\'\"\>]/).each{|x|
      arr << hostinfo_of_url(x[0].downcase) if x[0].size>8 && x[0].include?('.')
    }
    arr.uniq
  end

  def is_bullshit_host?(host)
    $hosts = %w|.i.sohu.com .tumblr.com .soufun.com .ymjx168.com .ninemarket.com .12market.com .cailiao.com .taobao.com|
    $hosts.each{|h|
      return true if host.include?(h)
    }
    false
  end

  def is_bullshit_ip?(ip)
    $ips = %w|192.126.115. 198.204.238. 192.151.145. 146.71.35. 23.245.66. 42.121.52. 208.66.76. 162.255.181. 107.148.40. 108.186.70. 107.149.82. 204.12.248. 122.9.125. 159.63.88. 69.90.191. 76.74.218. 162.211.24. 107.6.46. 142.54.190. 198.204.234. 8.5.1. 64.74.223. 23.82.61. 174.139.171. 107.183.22. 103.240.183. 192.169.109. 199.182.234. 23.81.36. 23.248.213. 107.163.136. 107.163.132. 103.248.36. 107.149.121. 101.226.10. 23.27.192. 219.139.130. 146.148.150. 146.148.151. 146.148.152. 146.148.153. 107.183.41. 23.224.45. 116.212.115. 23.110.102.|
    $ips.each{|bip|
      return true if ip.include?(bip)
    }
    false
  end

end