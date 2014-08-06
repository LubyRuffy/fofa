#!/usr/bin/env ruby
#encoding: utf-8
require 'guess_html_encoding'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'open-uri'
require 'socket'
require 'pp'
#require 'hexdump'

$cli = false
$cli = true if __FILE__==$0

def get_utf8(c)
  #c.hexdump
  c = c.force_encoding('UTF-8')
  if !c.valid_encoding?
    c = c.force_encoding("GB18030")
    #puts "unknow charset" if !c.valid_encoding?
    c = c.encode('UTF-8', :invalid => :replace, :replace => '^')
    #c.hexdump
  end
  c
end

def get_http(url, following=0)
  resp = {:error=>true, :errstring=>'', :code=>999, :url=>url, :title=>nil, :ip=>nil, :body=>nil}
  return resp if following>2
  begin
    url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
    url = URI.encode(url)
    uri = URI(url)
    resp[:host] = uri.host
    ip = uri.host
    if ip =~ /^[0-9.]*$/
      resp[:ip] = ip
    else
      ip = Socket.getaddrinfo(uri.host, nil) 
      return resp if !ip || !ip[0] || !ip[0][2]
      resp[:ip] = Socket.getaddrinfo(uri.host, nil)[0][2] 
    end
    resp[:port] = uri.port
    Net::HTTP.start(uri.host, uri.port) do |http|
      http.open_timeout = 10
      http.read_timeout = 10
      request = Net::HTTP::Get.new uri.request_uri
      request['Host'] = uri.host
      request['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'
      request['Accept-Encoding'] = 'gzip,deflate,' unless (ENV['OS'] == 'Windows_NT')  #windows下处理gzip暂时有点问题 ,暂时不支持sdch
      request['Accept-Charset'] = 'GBK,utf-8;q=0.7,*;q=0.3'
      request['Accept-Language'] = 'zh-CN,zh;q=0.8' #http://www.youyi.gov.cn/yyfm/homepage.shtml different of title
      begin
        response = http.request request # Net::HTTPResponse object
        if response.code.to_i == 301 || response.code.to_i == 302
          #  puts "redirect"
          if response['location'].include?("http://")
            return get_http(response['location'], following+1)
          else
            return get_http("http://"+resp[:host]+"/"+response['location'], following+1)
          end
        end
        resp[:code] = response.code
        resp[:message] = response.message
        resp[:http_version] = response.http_version
        resp[:header] = response.header
        resp[:error] = false
        html = ''
        if response.header[ 'Content-Encoding' ].eql?( 'gzip' )
          sio = StringIO.new( response.body )
          gz = Zlib::GzipReader.new( sio )
          html = gz.read()
        elsif response.header[ 'Content-Encoding' ].eql?( 'deflate' )
          html = Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate( response.body )
        else
          html = response.body
        end
        utf8html = get_utf8 html
        puts utf8html if $test
        resp[:body] = utf8html
        page = Nokogiri::HTML(utf8html) 
        resp[:title] = page.css('title')
        resp[:title] = page.at_css('title') if !resp[:title]
        if !resp[:title] || resp[:title].size<1
          uri = utf8html.scan(/location.href\s*=\s*["'](.*?)["']/)
          #document.location.href = "/gb/node2/node3/index.html";
          if uri and uri[0] and uri[0][0]
            puts uri[0][0]
            if uri[0][0].include?("http://")
              return head_http(uri[0][0], following+1)
            else
              return head_http("http://"+resp[:host]+uri[0][0], following+1)
            end
          else
          end
        end

      rescue Timeout::Error => e
        resp[:code] = 999
      rescue =>e
        resp[:code] = 998
        resp[:errstring] = e.inspect + ":" + e.backtrace.to_s
      end
    end
  rescue Timeout::Error  => the_error
    resp[:error] = true
    resp[:errstring] = "Timeout::Error of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
  rescue OpenURI::HTTPError => the_error
    resp[:error] = true
    resp[:errstring] = "OpenURI::HTTPError of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
  rescue SystemCallError => the_error
    resp[:error] = true
    resp[:errstring] = "SystemCallError of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
  rescue SocketError => the_error
    resp[:error] = true
    resp[:errstring] = "SocketError of : #{url}\n error:#{$!} at:#{$@}\nerror : #{the_error}"
  rescue => err
    resp[:error] = true
    resp[:errstring] = "Unknown Exception of : #{url}\n error:#{$!} at:#{$@}\nerror : #{err}"
  end

  resp
end


def run!
  pp get_http("www.1wsoft.cn")
end
run! if $cli 
