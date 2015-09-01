#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'logger'
require 'open-uri'
require 'nokogiri'
require 'yaml'
require 'json'

#ssh -qTfnN -D 42873 demo@demo.xxx.com
#ENV['http_proxy'] = 'http://127.0.0.1:42873'
class BingSearch
  def initialize(logger=nil)
    @logger = logger || Logger.new(STDOUT)  #输出到控制台
  end

  def search(query, options={})
    query = URI.escape(query)
    res = []
    count = 50
    page = options[:page] || 1

    first = ((page - 1) * count) + 1
    url = 'http://cn.bing.com/search?q='+query+'&first='+first.to_s
    @logger.debug "page #{page}, #{url}"
    html = open(url, { 'Cookie' => "SRCHHPGUSR=CW=582&CH=801&DPR=2&NEWWND=1&NRSLT=#{count}&SRCHLANG="}).read
    doc = Nokogiri::HTML(html)
    lis = doc.css('ol li.b_algo')
    lis.each{|li|
      res << li.text
    }
    @logger.debug res.size
    res
  rescue => e
    @logger.fatal e
    []
  end

  #自动翻页
  def searchall(query)
    res = []
    #第5页开始提示验证码，关键字：challengepic，所以取4页就好
    (1..4).each{|page|
      items = search(query, :page => page)
      res += items
      break if items.size<40
    }

    res.uniq
  rescue => e
    @logger.fatal e
    []
  end
end

class BingApiSearch
  def initialize(logger=nil)
    @logger = logger || Logger.new(STDOUT)  #输出到控制台

    absolute_path = File.expand_path(File.dirname(__FILE__))
    db_yml = File.join(absolute_path, '..', '..', '..', '..', 'config', 'database.yml')
    rails_env = ENV['RAILS_ENV'] || 'development'
    @bingapi = YAML.load_file(db_yml)[rails_env]['bingapi']
    unless @bingapi
      @logger.fatal "No bingapi config, please check it's ok!"
    end
  end

  def search(query, options={})
    query = URI.escape(query)
    res = []
    count = 50
    page = options[:page] || 1

    first = (page - 1) * count
    url = "https://api.datamarket.azure.com/Bing/Search/v1/Web?Query=%27#{query}%27&$format=json&$skip=#{first.to_s}&$top=#{count.to_s}"
    @logger.debug "page #{page}, #{url}"
    json = open(url, http_basic_authentication: ['',@bingapi],
                'Accept' => 'application/json').read
    doc = JSON.parse(json)
    doc
  rescue => e
    @logger.fatal e
    nil
  end

  #自动翻页
  def searchall(query)
    res = []
    page = 1
    while doc = search(query, {page:page})
      res += doc['d']['results'].map{|r| r['Description']+' '+r['Description'] }
      if doc['d']['__next'] && doc['d']['__next'].size>0
        page += 1
      else
        break
      end
    end
    res
  rescue => e
    @logger.fatal e
    []
  end
end

if __FILE__ == $PROGRAM_NAME
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG
  target = '"@sohu-inc.com"'
  target = '"'+ARGV[0]+'"' if ARGV[0]
  #body = BingSearch.new().search('"@sohu-inc.com"')
  body = BingApiSearch.new().searchall( target )
  puts body
end