#!/usr/bin/env ruby
# encoding: utf-8
require 'domainatrix'
require 'sidekiq'
require 'thread/pool'
require 'script_detector'
root_path = File.expand_path(File.dirname(__FILE__))
require root_path+"/lrlink.rb"
require root_path+"/webdb2_class.rb"
require root_path+"/httpmodule.rb"

class Processor
  include HttpModule
  include Lrlink
  include Sidekiq::Worker

  sidekiq_options :queue => :process_url, :retry => 3, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def initialize(webdb=nil)
    root_path = File.expand_path(File.dirname(__FILE__))

    @@g_webdb ||= webdb
    @@g_webdb ||= WebDb.new(root_path+"/../../../config/database.yml")

    @webdb = @@g_webdb
  end

  def perform(url)
    add_host_to_webdb(url,false)
  end

  def ip_dec(host)
    subs = host.split('.')
    if subs.size == 4
      zerosubs = subs.map{|s| Integer(s)}
      if zerosubs.size==4
        return zerosubs.join('.')
      end
    end
    nil
  rescue => e
    nil
  end

  #最上层函数，添加host到数据库
  def add_host_to_webdb(host, force=false, addlinkhosts=true)
    host = hostinfo_of_url(host.downcase)
    return -1 unless host
    return -1 if host.include?('/')
    return -2 if is_bullshit_host?(host) || @webdb.redis_black_host?(host)
    only_host = host_of_url(host)
    ip = get_ip_of_host(only_host)
    return -3 if is_bullshit_ip?(ip)  || @webdb.is_redis_black_ip?(ip)

    #if ip_dec(only_host)
    #  host = ip_dec(only_host)
    #  ip = host
    #end

    domain_is_ip = false
    if host =~ /\d+\.\d+\.\d+\.\d/
      if ip_dec(only_host) #0000314.00000014.0306.000000375
        return -4
      end
      domain = host
      domain_is_ip = true
    elsif ip_dec(only_host) #这种类型的ip：0x0079.0x000000000000000028.0x0083.00257
      return -4
    else
      domain_info = get_domain_info_by_host(host)
      #pp domain_info
      return -4 if !domain_info
      domain = domain_info.domain+'.'+domain_info.public_suffix
      return -2 if @webdb.is_redis_black_domain?(domain)
    end

    #检查是否需要更新
    need_update,exists_host=@webdb.need_update_host(host)
    if !force && !need_update
      #puts "#{host} no need to update"
      return 1
    end

    #更新检查时间
    @webdb.update_subdomain_if_exists(host, exists_host)

    #获取http信息
    http_info = get_http(host)
    if http_info && ! http_info[:error]
      return -5 if is_bullshit_ip?(http_info[:ip])
      return -6 if domain_info && is_bullshit_title?(http_info[:title], domain_info.subdomain)

      #puts host
      #pp http_info
      #更新ip
      #@webdb.insert_ip_to_ipaddr(http_info[:ip])

      if domain_is_ip
        @webdb.update_host_to_subdomain(host, domain, '', http_info, exists_host)
      else
        #更新根域名表
        #@webdb.insert_domain_to_rootdomain(domain, exists_host)
        #更新子域名表
        @webdb.update_host_to_subdomain(host, domain, domain_info.subdomain, http_info, exists_host)
      end

      utf8html = http_info[:utf8html]

      if addlinkhosts
        hosts = get_linkes(utf8html).select {|h|
          !@webdb.redis_black_host?(h) && !@webdb.mysql_exists_host(h) && !is_bullshit_host?(h) && !@webdb.is_redis_black_ip?(get_ip_of_host(host_of_url(h)))
          #&& !@webdb.redis_has_host?(h)
        }

        if hosts.size>0
            hosts.each {|h|
              Sidekiq::Client.enqueue(Processor, h)
            }
        end
      end

      return 0
    else
      @webdb.redis_inc_failed_host(host)
      @webdb.insert_host_to_error_table(host, "#{Socket.gethostname} : http failed! #{http_info[:errstring]}") if http_info[:write_error]
      return -7
    end
  end

end
