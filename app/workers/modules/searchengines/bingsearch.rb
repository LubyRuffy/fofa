#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'open-uri'
require 'nokogiri'

#ssh -qTfnN -D 42873 demo@demo.youareempire.co.uk
#ENV['http_proxy'] = 'http://127.0.0.1:42873'
class BingSearch
  def self.search(query, options={})
    query = URI.escape(query)
    count = 50
    page = options[:page] || 1
    first = ((page - 1) * count) + 1
    html = open('http://cn.bing.com/search?q='+query, { 'Cookie' => "SRCHHPGUSR=CW=582&CH=801&DPR=2&NEWWND=1&NRSLT=#{count}&SRCHLANG="}).read
    doc = Nokogiri::HTML(html)
    doc.css('ol li.b_algo').map{|li|
      li.text
    }
  rescue => e
    puts e
    [nil,nil]
  end

  #自动翻页
  def self.searchall(query)
    query = URI.escape(query)
    res = []
    count = 50

    #第5页开始提示验证码，关键字：challengepic，所以取4页就好
    (1..4).each{|page|
      first = ((page - 1) * count) + 1
      url = 'http://cn.bing.com/search?q='+query+'&first='+first.to_s
      puts "page #{page}, #{url}"
      html = open(url, { 'Cookie' => "SRCHHPGUSR=CW=582&CH=801&DPR=2&NEWWND=1&NRSLT=#{count}&SRCHLANG="}).read
      doc = Nokogiri::HTML(html)
      lis = doc.css('ol li.b_algo')
      i = 0
      lis.each{|li|
        res << li.text
        i += 1
      }
      puts i
      if i<count-5 #baidu知道会占位
        break
      end
    }

    res
  rescue => e
    puts e
    []
  end
end

if __FILE__ == $PROGRAM_NAME
  body = BingSearch.search('"@sohu-inc.com"')
  puts body
end