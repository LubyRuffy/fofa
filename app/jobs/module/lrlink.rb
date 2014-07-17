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
    if html
      html.scan(/(http[s]?:\/\/.*?)[ \/\'\"\>]/).each{|x|
        if x[0].size>8 && x[0].include?('.')
          hostinfo = hostinfo_of_url(x[0].downcase)
          arr << hostinfo if hostinfo
        end
      }
    end
    arr.uniq
  end

  def is_bullshit_host?(host)
    $hosts = %w|.i.sohu.com .tumblr.com .soufun.com .ymjx168.com .ninemarket.com .12market.com .cailiao.com .taobao.com .blogfa.com .parsiblog.com .blog.ir .mihanblog.com .persianblog.ir .niniweblog.com .lapozz.hu .blogcu.com .blogsky.com .deviantart.com rpod.ru .beon.ru .ieskok.lt .vk.me .qaix.com .gyxu.com .ltalk.ru .userapi.com .olx.bg .digart.pl .flog.pl .fmix.pl .uol.ua .rock.cz .blog.is .yjycw.com .243mm.com .bxlwt.com .mmfj.com .blox.pl .bloog.pl .huamu.cn .8671.net .blog.pl .onet.pl .salon24.pl .pinger.pl .blog.hexun.com .blog.163.com .canalblog.com .skyrock.com .1254.it .wanknews.com .soup.io .interia.pl .blogbus.com .idnes.cz .bloblo.pl .startpagina.nl .tianya.cn .blog.sohu.com .blogchina.com .tianyablog.com .blog.bokee.net .1688.com .100ye.com .b2b168.com .net114.com .5d6d.com .goedbegin.nl|
    $hosts.each{|h|
      return true if host.end_with?(h)
    }
    false
  end

  def is_bullshit_ip?(ip)
    $ips = %w|192.126.115. 198.204.238. 192.151.145. 146.71.35. 23.245.66. 42.121.52. 208.66.76. 162.255.181. 107.148.40. 108.186.70. 107.149.82. 204.12.248. 122.9.125. 159.63.88. 69.90.191. 76.74.218. 162.211.24. 107.6.46. 142.54.190. 198.204.234. 8.5.1. 64.74.223. 23.82.61. 174.139.171. 107.183.22. 103.240.183. 192.169.109. 199.182.234. 23.81.36. 23.248.213. 107.163.136. 107.163.132. 103.248.36. 107.149.121. 101.226.10. 23.27.192. 219.139.130. 146.148.150. 146.148.151. 146.148.152. 146.148.153. 107.183.41. 23.224.45. 116.212.115. 23.110.102. 198.56.177. 107.181.245. 107.181.242. 107.160.38. 142.0.142. 103.244.148. 23.80.51. 67.229.62. 144.76.203. 74.82.63. 103.24.92. 23.105.79. 107.183.152. 107.189.149. 107.189.134. 107.189.154. 107.149.155. 23.238.206. 23.228.225. 23.228.219. 198.13.100. 192.169.105. 69.12.87. 23.245.134. 69.12.87. 172.240.95. 174.139.6. 173.208.68. 115.126.23. 108.62.237. 173.208.68. 172.240.60. 107.178.159. 23.245.100. 107.160.84. 107.160.83. 23.110.25. 23.110.46. 23.83.57. 194.79.52. 107.189.144. 148.163.55. 23.80.248. 23.104.3. 23.80.209. 172.255.207. 162.218.118. 91.195.240. 23.82.231. 23.104.19. 23.104.20. 162.209.240. 162.209.241. 107.163.130. 172.247.230. 172.247.231. 103.242.135. 172.240.120. 107.178.92. 23.110.244. 23.80.169. 107.189.129. 23.226.64. 148.163.16. 192.80.155. 205.209.169. 23.107.74. 199.48.69. 198.98.97. 137.175.124. 192.80.161. 23.80.77. 23.104.160. 23.80.90. 23.80.189. 108.171.249. 23.89.167. 23.80.182. 198.56.219. 23.80.226. 23.245.152. 23.104.160. 107.160.169. 192.157.223. 192.157.247. 23.80.165. 23.89.157. 124.248.251. 124.248.244. 103.27.124. 23.80.193. 107.189.146. 174.129.12. 23.88.183. 23.244.147. 107.189.157. 211.149.187. 122.10.114. 23.226.76. 192.250.205. 198.27.91. 23.110.58. 174.139.100. 174.139.96. 174.139.43. 59.39.7. 46.28.209. 211.149.204. 222.215.230. 107.149.55.|
    $ips.each{|bip|
      return true if ip.start_with?(bip)
    }
    false
  end

end