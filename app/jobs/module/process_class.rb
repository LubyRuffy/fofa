#!/usr/bin/env ruby
# encoding: utf-8
require 'domainatrix'
require 'resque'
require 'thread/pool'
require 'resque-loner'
require 'script_detector'
root_path = File.expand_path(File.dirname(__FILE__))
require root_path+"/lrlink.rb"

class Thread::Pool
  def wait_until_finished
    until self.wait_done.nil?
      self.wait_done
    end
  end
end



class QuickProcessor
  include HttpModule
  include Lrlink
  include Resque::Plugins::UniqueJob

  @queue = "quick_process_host"
  @webdb = nil
  @pool = nil

  def initialize(webdb, queue=nil)
    @webdb = webdb
    @queue = queue || "quick_process_host"
  end

  def self.perform(url)
    root_path = File.expand_path(File.dirname(__FILE__))
    @@db ||= WebDb.new(root_path+"/../../../config/database.yml")
    @@p ||= QuickProcessor.new( @@db)
    #puts "#{@@p.class.name}.perform called"
    @@p.add_host_to_webdb(url)
  end

  #最上层函数，添加host到数据库
  def add_host_to_webdb(hosts)
    @pool ||= Thread.pool(20)
    hosts.split(',').each {|h|
      if !@webdb.mysql_exists_host(h) && !is_bullshit_host?(h)
        @pool.process(h) {|host|
          domain = nil
          host = host.downcase
          if host =~ /\d+\.\d+\.\d+\.\d/
            domain = host
          else
            domain_info = get_domain_info_by_host(host)
            domain = domain_info.domain+'.'+domain_info.public_suffix if  domain_info
          end

          if domain
            #获取http信息
            http_info = get_http(host)
            if http_info && ! http_info[:error]
              return -4 if is_bullshit_ip?(http_info[:ip])
              @webdb.update_host_to_subdomain(host, domain, domain_info.subdomain, http_info)
            end
          end
        }
      end
    }
    @pool.wait_until_finished
    #@pool.shutdown
  end
end

class Processor
  include HttpModule
  include Lrlink
  include Resque::Plugins::UniqueJob

  @queue = "process_url"
  @webdb = nil

  def initialize(webdb, queue=nil)
    @webdb = webdb
    @queue = queue || "process_url"
  end

  def self.perform(url)
    root_path = File.expand_path(File.dirname(__FILE__))
    @@db ||= WebDb.new(root_path+"/../../../config/database.yml")
    @@p ||= Processor.new( @@db)
    #puts "#{@@p.class.name}.perform called"
    @@p.add_host_to_webdb(url,false)
  end

  #最上层函数，添加host到数据库
  def add_host_to_webdb(host, force=false)
    host = host.downcase
    return -1 if host.include?('/')
    return -2 if is_bullshit_host?(host)

    domain_is_ip = false
    if host =~ /\d+\.\d+\.\d+\.\d/
      domain = host
      domain_is_ip = true
    else
      domain_info = get_domain_info_by_host(host)
      #pp domain_info
      return -3 if !domain_info
      domain = domain_info.domain+'.'+domain_info.public_suffix
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
      return -4 if is_bullshit_ip?(http_info[:ip])
      return -5 if domain_info && is_bullshit_title?(http_info[:title], domain_info.subdomain)

      #puts host
      #pp http_info
      #更新ip
      @webdb.insert_ip_to_ipaddr(http_info[:ip])

      if domain_is_ip
        @webdb.update_host_to_subdomain(host, domain, '', http_info, exists_host)
      else
        #更新根域名表
        @webdb.insert_domain_to_rootdomain(domain)
        #更新子域名表
        @webdb.update_host_to_subdomain(host, domain, domain_info.subdomain, http_info, exists_host)
      end

      #队列如果不长，就递归添加，否则只添加中文的网站
      root_path = File.expand_path(File.dirname(__FILE__))
      rails_env = 'production'
      resque_config = YAML.load_file(root_path+"/../../../config/database.yml")
      Resque.redis = "#{resque_config[rails_env]['redis']['host']}:#{resque_config[rails_env]['redis']['port']}"
      queue_len =Resque.redis.llen("queue:#{@queue}").to_i
      chinese = (http_info[:title] && http_info[:title].chinese?)
      if queue_len<20000 || host.include?('.cn') || chinese
        utf8html = http_info[:utf8html]
        hosts = get_linkes(utf8html).select {|h|
          !@webdb.mysql_exists_host(h) && !is_bullshit_host?(h) #&& Resque.redis.zscore("rootdomains", domain)<2000
        }

        if hosts.size>0
          len = hosts.inject(0){|memo,s|memo+s.length}
          sl = len/hosts.size
          port_len = hosts.select{|h| h.include?(':') }.size

          #if sl<17 && port_len<10 #全是:123这样的说明是垃圾站，同时平均长度超长的说明是dns泛解析垃圾站
          if port_len<15 && sl<25
            hosts.each {|h|
              Resque.enqueue(Processor, h)
            }
            #Resque.enqueue(QuickProcessor, hosts.join(','))
          end
        end
      end

      return 0
    else
      @webdb.insert_host_to_error_table(host, "#{Socket.gethostname} : http failed! #{http_info[:errstring]}") if http_info[:write_error]
      return -3
    end
  end

end

class RealtimeProcessor < Processor
  include HttpModule
  include Lrlink
  include Resque::Plugins::UniqueJob

  @queue = "realtime_process_list"
  @webdb = nil

  def initialize(webdb, queue=nil)
    @webdb = webdb
    @queue = queue || "realtime_process_list"
  end

  def self.perform(url)
    root_path = File.expand_path(File.dirname(__FILE__))
    @@db ||= WebDb.new(root_path+"/../../../config/database.yml")
    @@p ||= RealtimeProcessor.new( @@db, "realtime_process_list" )
    #puts "#{@@p.class.name}.perform called"
    @@p.add_host_to_webdb(url,false)
  end
end