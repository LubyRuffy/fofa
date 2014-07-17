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
    $hosts=%q{.100ye.com
.1254.it
.12market.com
.1688.com
.243mm.com
.5d6d.com
.8671.net
.alibaba.com
.b2b168.com
.beon.ru
.bloblo.pl
.blog.163.com
.blog.bokee.net
.blog.hexun.com
.blog.ir
.blog.is
.blog.pl
.blog.sohu.com
.blogbus.com
.blogchina.com
.blogcu.com
.blogfa.com
.blogsky.com
.bloog.pl
.blox.pl
.biz72.com
.bxlwt.com
.cailiao.com
.canalblog.com
.deviantart.com
.digart.pl
.flog.pl
.fmix.pl
.goedbegin.nl
.gyxu.com
.huamu.cn
.i.sohu.com
.idnes.cz
.ieskok.lt
.interia.pl
.lapozz.hu
.ltalk.ru
.mihanblog.com
.mmfj.com
.net114.com
.ninemarket.com
.niniweblog.com
.olx.bg
.onet.pl
.parsiblog.com
.persianblog.ir
.pinger.pl
.qaix.com
.qjy168.com
.rock.cz
.rpod.ru
.salon24.pl
.skyrock.com
.soufun.com
.soup.io
.startpagina.nl
.taobao.com
.tianya.cn
.tianyablog.com
.tumblr.com
.uol.ua
.userapi.com
.vk.me
.wanknews.com
.yjycw.com
.ymjx168.com}
    $hosts.each_line{|h|
      return true if h && h.size>5 && host.end_with?(h.strip)
    }
    false
  end

  def is_bullshit_ip?(ip)
    $ips = %q{101.226.10.
103.24.92.
103.240.183.
103.242.135.
103.244.148.
103.248.36.
103.27.124.
103.27.177.
107.148.40.
107.149.121.
107.149.155.
107.149.55.
107.149.82.
107.160.169.
107.160.38.
107.160.83.
107.160.84.
107.163.130.
107.163.132.
107.163.136.
107.167.74.
107.178.159.
107.178.92.
107.181.242.
107.181.245.
107.183.152.
107.183.22.
107.183.41.
107.189.129.
107.189.134.
107.189.144.
107.189.146.
107.189.149.
107.189.154.
107.189.157.
107.6.46.
108.171.249.
108.186.70.
108.62.237.
115.47.54.136
115.126.23.
116.212.115.
116.212.126.
116.254.222.
118.99.21.
118.99.57.
122.10.114.
122.9.125.
124.248.229.
124.248.244.
124.248.251.
137.175.109
137.175.124.
137.175.2.
137.175.57.
137.175.61.
142.0.142.
142.54.190.
144.76.203.
146.148.150.
146.148.151.
146.148.152.
146.148.153.
146.71.35.
148.163.16.
148.163.55.
159.63.88.
162.209.240.
162.209.241.
162.211.24.
162.218.118.
162.255.181.
172.240.120.
172.240.60.
172.240.95.
172.247.230.
172.247.231.
172.255.207.
173.208.68.
173.208.68.
174.129.12.
174.139.100.
174.139.171.
174.139.43.
174.139.6.
174.139.96.
192.126.115.
192.151.145.
192.157.223.
192.157.247.
192.169.105.
192.169.109.
192.250.205.
192.80.155.
192.80.161.
192.99.215.
194.79.52.
198.13.100.
198.204.234.
198.204.238.
198.27.91.
198.56.177.
198.56.219.
198.98.97.
199.182.234.
199.48.69.
204.12.248.
205.209.169.
208.66.76.
211.149.187.
211.149.204.
219.127.222.
219.139.130.
222.215.230.
23.104.160.
23.104.160.
23.104.19.
23.104.20.
23.104.3.
23.105.79.
23.105.83.
23.107.74.
23.110.102.
23.110.244.
23.110.25.
23.110.46.
23.110.58.
23.224.45.
23.226.64.
23.226.76.
23.228.219.
23.228.225.
23.238.206.
23.244.147.
23.244.20.
23.245.100.
23.245.134.
23.245.152.
23.245.54.
23.245.66.
23.248.213.
23.27.192.
23.80.165.
23.80.169.
23.80.182.
23.80.189.
23.80.193.
23.80.209.
23.80.226.
23.80.248.
23.80.51.
23.80.77.
23.80.90.
23.81.36.
23.82.231.
23.82.61.
23.83.57.
23.88.183.
23.89.157.
23.89.167.
23.90.165.
42.121.52.
42.96.195.43
46.28.209.
59.39.7.
59.45.75.
60.28.245.173
63.141.225.
63.141.226.
64.74.223.
65.19.157.
67.229.62.
69.12.87.
69.12.87.
69.165.69.
69.90.191.
74.82.63.
76.74.218.
8.5.1.
91.195.240.}
    $ips.each_line{|bip|
      return true if bip && bip.size>4 && ip.start_with?(bip.strip)
    }
    false
  end

end