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
end