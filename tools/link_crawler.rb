#!/usr/bin/env ruby
#用于进行host爬行，从一个入口开始，只获取首页的外链，可以设置过滤器
#Usage: $0 <host> [MATCH_PATTERN_TO_PROCESS]
root_path = File.expand_path(File.dirname(__FILE__))
require 'pp'
#require 'awesome_print'
require 'rubygems'
require 'domainatrix'
require root_path+'/../app/jobs/module/httpmodule.rb'
require 'active_record'

include HttpModule

@hosts = []
@options = {:cachetime=>864000}
$pattern = nil
$max_site = 10000

def add_host(host, src)
  host = host.downcase
  find_h = @hosts.select { |h|
    h[:host] == host
  }[0]

  unless find_h
    url = "http://"+host unless host.include? "http://" or host.include? "https://"
    h = {host:host, url:url, size:1, from:[src], to:[], processed:false}

    if !$pattern || ($pattern && host.include?($pattern) )
      info = "#{src} -> #{host}"
      puts info
      @hosts << h
      r = `curl http://www.fofa.so/api/addhost?host=#{host} >/dev/null 2>&1`
    end
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

def process_url(h, href)
  if href.include?("http://") || href.include?("https://")
    begin
      u = URI.join(h[:url], href)
      new_host = hostinfo_of_url(u.to_s)
      add_host(new_host, h[:host]) if h[:host] != new_host
    rescue => e
      puts "[ERROR] process error of [#{href}]"
    end
  end
end

def get_links(h)
  return unless h && h[:url]
  url = h[:url]
  html = load_info url
  if !html[:error]
=begin
    doc = Nokogiri::HTML(html[:utf8html])
    doc.css("a").each{ |a|
      if a['href']
        href = a['href']
        process_url h,href
      end
    }
=end

    #window.open location.href
    if html[:utf8html]
      html[:utf8html].scan(/(http[s]?:\/\/.*?)[ \/\'\"\>]/).each{|x|
        process_url h,x[0] if x[0].size>8
      }
    end
  else
    puts "http error"
  end
end

def main(host)
  puts "get links of #{host}"
  if host
    add_host(host, nil)
  end

  while @hosts.select {|h| h[:processed]}.size<$max_site && @hosts.select {|h| !h[:processed] }.size>0
    h = @hosts.select {|h| !h[:processed] }[0]
    puts h
    get_links h
    h[:processed] = true
  end
end

if ARGV.size>0
  $pattern = ARGV[1] if ARGV.size>1
  $max_site = ARGV[2].to_i if ARGV.size>2
  main(ARGV[0])
else
  puts "Usage: $0 <host> [MATCH_PATTERN_TO_PROCESS]"
  puts "Which pattern like '.com.cn'"
end

