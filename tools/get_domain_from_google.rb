#!/usr/bin/env ruby

#Description:Script for DNS Recon
#Author: Carlos Perez carlos_perez[at]darkoperator.com
require 'open-uri'
require 'json'
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../app/workers/module/lrlink.rb"
include Lrlink
require 'colorize'

require 'getoptlong'
require 'rubygems'
#require 'Net/DNS'
#http://rubyforge.org/projects/pnet-dns/
require 'ip'
#http://rubyforge.org/projects/ip-address/
trap "SIGINT", 'exit'


def get_domain_from_google(query)
  subdomains = []
  (1..100).each{|n|
    print '.'
    #puts "==============PAGE #{n}==============="
    added = false
    added_arr = []

    url = "https://www.google.com.hk/search?hl=en&lr=&ie=UTF-8&q=" + query + "&start=" + (n*100).to_s + "&sa=N&filter=0&num=100"
    #puts url
    get_linkes(open(url).read).select{|l|
      domain_info = get_domain_info_by_host(l)
      return false unless domain_info
      true
    }.each{|l|
      hostinfo = hostinfo_of_url(l)
      if !subdomains.include?(hostinfo)
        added = true
        added_arr << hostinfo
        subdomains << hostinfo
        puts hostinfo
      end
    }
    unless added
      break
    end
    #puts added_arr
  }
  subdomains.uniq
end

def addhost(hosts)
  uri = URI('http://fofa.so/api/addhostp')
  res = Net::HTTP.post_form(uri, 'host' => hosts.join(','))
  puts "response:"+res.body
end

hosts = get_domain_from_google(ARGV[0])
puts hosts.size
addhost(hosts)
