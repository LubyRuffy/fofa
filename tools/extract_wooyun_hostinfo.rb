#!/usr/bin/env ruby

require 'open-uri'
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/workers/module/lrlink.rb"
require @root_path+"/../app/workers/module/httpmodule.rb"
include Lrlink
include HttpModule
require 'colorize'
require 'openssl'

class String
  def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end

def addhost(hosts)
  uri = URI('http://www.fofa.so/api/addhostp')
  res = Net::HTTP.post_form(uri, 'host' => hosts.join(','))
  puts "response:"+res.body
end

(25..1100).each{|page|
  puts "=========#{page}=========="
  list_page = "http://www.wooyun.org/bugs/new_public/page/#{1}"
  http = get_http(list_page, list_page)
  #puts http
  listhtml = http[:utf8html].string_between_markers '<table class="listTable">', '</table>'
  page = Nokogiri::HTML(listhtml)
  alinks = page.css('tr td a')
  alinks.each{|a|
    url = 'http://www.wooyun.org'+a['href']
    puts "---------#{url}----------"
    urls = get_links_deep(get_http(url)[:utf8html]).uniq
    puts urls
    addhost urls if urls.size>0
    sleep 1
  }
}