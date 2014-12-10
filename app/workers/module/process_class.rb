#!/usr/bin/env ruby
# encoding: utf-8
require 'domainatrix'
require 'sidekiq'
require 'thread/pool'
require 'script_detector'
require 'whois'
require 'json'
root_path = File.expand_path(File.dirname(__FILE__))
require root_path+"/lrlink.rb"
require root_path+"/webdb2_class.rb"
require root_path+"/httpmodule.rb"


class Uitask
  include HttpModule
  include Lrlink
  include Sidekiq::Worker

  sidekiq_options :queue => :ui_task, :retry => 1, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def initialize(webdb=nil)
    root_path = File.expand_path(File.dirname(__FILE__))

    @@g_webdb ||= webdb
    @@g_webdb ||= WebDb.new(root_path+"/../../../config/database.yml")

    @webdb = @@g_webdb
  end

  def getallhosts(domain, maxsize)
    black_host = [ /\d+\.qzone\.qq\.com/i,
                   /\d+\.qzone\.com/i,
                   /\d+\.foxmail\.com/i,
                   /\d+\.qq.qzone.com/i,
                   /\d+qq.qzone.com/i, ]
    res = @webdb.queryer.query("select host from subdomain where reverse_domain='#{Mysql2::Client.escape(domain.downcase.reverse)}' limit #{maxsize.to_i}")
    res.each{ |r|
      if r['host']
        unless black_host.find{|b| r['host']=~b }
          yield(r['host'])
        end
      end
    }
  end

  def getallips(host, maxsize)
    res = @webdb.queryer.query("select ip from subdomain where host='#{Mysql2::Client.escape(host.downcase)}'")
    res.each{ |r|
      if r['ip']
        yield(r['ip'])
      end
    }
  end

  def getalldomains(domain, maxsize)
    domains = [{domain:domain, finished:false}]
    emails = []
    companys = []
    while ( domains.detect{|d| !d[:finished] } || emails.detect{|e| !e[:finished] } )
      if domains.size>maxsize
        msg = "达到最大数限制，未登录状态最多显示200条。登录后可以达到1000条。"
        #puts msg
        yield(msg)
        break
      end

      #处理domains
      process_domain = domains.detect{|d| !d[:finished]}
      if process_domain
        puts "========= #{process_domain[:domain]} =========="
        res = @webdb.queryer.query("select ym from icp where DWMC=(select DWMC from icp where ym='#{Mysql2::Client.escape(process_domain[:domain])}' limit 1)")
        res.each{ |r|
          if r['ym']
            found_domain = domains.detect{|d| d[:domain].downcase==r['ym'].downcase}
            unless found_domain
              domains << {domain:r['ym'], finished:false}
              yield(r['ym'])
            end
          end
        }

        res = @webdb.queryer.query("select DWMC from icp where ym='#{Mysql2::Client.escape(process_domain[:domain])}' and DWXZ!='个人'")
        res.each{ |r|
          if r['DWMC']
            found_company = companys.detect{|d| d[:company].downcase==r['DWMC'].downcase}
            unless found_company
              unless @@blackc_coms.detect{|c| c && r['DWMC'].include?(c)}
                puts " #{process_domain[:domain]} -> #{r['DWMC']}"
                companys << {company:r['DWMC'], finished:false}
              end
            end
          end
        }
=begin
        res = @webdb.queryer.query("select whois_com from rootdomain where domain='#{Mysql2::Client.escape(process_domain[:domain])}'")
        res.each{ |r|
          if r['whois_com']
            found_company = companys.detect{|d| d[:company].downcase==r['whois_com'].downcase}
            unless found_company
              unless @@blackc_coms.detect{|c| c && r['whois_com'].include?(c)}
                puts " #{process_domain[:domain]} -> #{r['whois_com']}"
                companys << {company:r['whois_com'], finished:false}
              end
            end
          end
        }

        res = @webdb.queryer.query("select email from rootdomain where domain='#{Mysql2::Client.escape(process_domain[:domain])}'")
        res.each{ |rs|
          if rs['email']
            rs['email'].split(',').each{|email|
              email = email.split('\t').detect{|e| e.include?('@')}
              unless @@blackc_emails.detect{|e| e && email.include?(e)}
                found_email = emails.detect{|e| e[:email].downcase==email.downcase}
                unless found_email
                  puts " #{process_domain[:domain]} -> #{email}"
                  emails << {email:email, finished:false}
                end
              end
            }
          end
        }
=end
        process_domain[:finished] = true

      end

=begin
      #处理emails
      process_email = emails.detect{|e| !e[:finished]}
      if process_email
        puts "========= #{process_email[:email]} =========="
        res = @webdb.queryer.query("select domain from rootdomain where email='#{Mysql2::Client.escape(process_email[:email])}'")
        res.each{ |r|
          found_domain = domains.detect{|d| d[:domain].downcase==r['domain'].downcase}
          unless found_domain
            domains << {domain:r['domain'], finished:false}
            yield(r['domain'])
          end
        }
        process_email[:finished] = true
      end
=end
      #处理companys
      process_company = companys.detect{|c| !c[:finished]}
      if process_company
        puts "========= #{process_company[:company]} =========="
=begin
        res = @webdb.queryer.query("select domain from rootdomain where whois_com='#{Mysql2::Client.escape(process_company[:company])}' limit 1000")
        if res.size<1000
          res.each{ |r|
            found_domain = domains.detect{|d| d[:domain].downcase==r['domain'].downcase}
            unless found_domain
              domains << {domain:r['domain'], finished:false}
              yield(r['domain'])
            end
          }
        else
          #可能是个域名注册商
          puts "===> bad company name: #{process_company[:company]}"
        end
=end
        res = @webdb.queryer.query("select ym from icp where DWMC='#{Mysql2::Client.escape(process_company[:company])}'")
        res.each{ |r|
          if r['ym']
            found_domain = domains.detect{|d| d[:domain].downcase==r['ym'].downcase}
            unless found_domain
              domains << {domain:r['ym'], finished:false}
              yield(r['ym'])
            end
          end
        }

        process_company[:finished] = true
      end
    end
  end

  def perform(jobid, action, domain, maxsize=200)
    @@blackc_coms = ['HICHINA ZHICHENG TECHNOLOGY LTD.', 'MARKMONITOR INC.', 'CHENGDU WEST DIMENSION DIGITAL TECHNOLOGY CO., LTD.',
      'Public Interest Registry', 'ENAME TECHNOLOGY CO., LTD.', 'XIN NET TECHNOLOGY CORPORATION',
      'WEB COMMERCE COMMUNICATIONS LIMITED DBA WEBNIC.CC',
      'Japan Registry Services', 'ENOM, INC.','35 TECHNOLOGY CO., LTD',
      'ASCIO TECHNOLOGIES, INC.', 'GODADDY.COM, LLC', 'NETWORK SOLUTIONS, LLC.', 'CSC CORPORATE DOMAINS, INC.','NAME.COM LLC']
    @@blackc_emails = ['domainadm@hichina.com', 'whoisprivacyprotectionservices.com', 'whois.private.service@gmail.com', 'China NIC']
    addmsg(jobid, 'start dumping...')
    case action
      when 'alldomains' #格式就是一行一个domain
        getalldomains(domain, maxsize){|d|
          addmsg(jobid, d)
        }
      when 'alldomainsfrom' #格式就是from: domain, to: d
        getalldomains(domain, maxsize){|d|
          addmsg(jobid, {from:domain, to:{value:d, type:"domain"}}.to_json)
        }
      when 'gethosts' #格式就是from: domain, to: host
        getallhosts(domain, 1000){|d|
          addmsg(jobid, {from:domain, to:{value:d, type:"host"}}.to_json)
        }
      when 'getips' #格式就是from: domain, to: host
        getallips(domain, maxsize){|d|
          ipnet = d.split('.')[0..2].join('.')
          addmsg(jobid, {from:domain, to:{value:ipnet, type:"ip", ip:d}}.to_json)
        }
      else
        addmsg(jobid, 'unknown action')
    end
    addmsg(jobid, '<<<finished>>>')

  end

  def addmsg(jobid,msg)
    key = "fofa:task:#{jobid}"
    @webdb.redis.rpush(key, msg)
    @webdb.redis.expire(key, 2*60) #2分钟过期
  end

end


class WhoisTask
  include Sidekiq::Worker

  sidekiq_options :queue => :whois_task, :retry => 3, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def initialize(webdb=nil)
    root_path = File.expand_path(File.dirname(__FILE__))

    @@g_webdb ||= webdb
    @@g_webdb ||= WebDb.new(root_path+"/../../../config/database.yml")

    @webdb = @@g_webdb
  end

  def perform(rootdomain, force=false)
    return
    return if rootdomain.include? '.edu.cn'
    need_update, exist_domain = @webdb.need_update_domain(rootdomain)
    if need_update || force
      r = Whois.whois(rootdomain)
      if r
        email=''
        emails = r.to_s.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).uniq
        new_emails = emails.delete_if{|e| e.include?('abuse') || e.include?('private') }
        emails = new_emails if new_emails.size>0
        email = emails.join(',') if emails
        #r.created_on, r.expires_on, r.updated_on
        whois_com = ''

        %w|registrant_contact technical_contact registrar admin_contacts|.each{|name|
          value = r.properties[name.to_sym]
          if value
            if value.kind_of?(Array)
              whois_com = value[0][:name] if value.size>0 && value[0][:name]
            else
              whois_com = value[:name] if value[:name]
            end
          end
        }

        ns_info = r.nameservers.map{|ns| ns.name}.join(',')
        @webdb.db_insert_domain(rootdomain.downcase, r.to_s, whois_com, email, ns_info)
      end
    end
  end

end


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

  def perform(url, force=false, addlinkhosts=true, userid=0)
    add_host_to_webdb(url, force, addlinkhosts, userid)
  end

  #最上层函数，添加host到数据库
  def add_host_to_webdb(host, force=false, addlinkhosts=true, userid=0)
    host = hostinfo_of_url(host.downcase)
    return -1 unless host
    return -1 if host.include?('/') && !host.include?('https://')
    return -2 if @webdb.redis_black_host?(host)
    only_host = host_of_url(host)

    domain_is_ip = false
    if only_host =~ /\d+\.\d+\.\d+\.\d/
      if ip_dec?(only_host) #0000314.00000014.0306.000000375
        return -4
      end
      domain = host
      domain_is_ip = true
    elsif ip_dec?(only_host) #这种类型的ip：0x0079.0x000000000000000028.0x0083.00257
      return -4
    else
      domain_info = get_domain_info_by_host(host)
      #pp domain_info
      return -4 if !domain_info
      domain = domain_info.domain+'.'+domain_info.public_suffix
      return -2 if @webdb.is_redis_black_domain?(domain)
    end

    #泛域名解析这里会超时，尽可能往下放
    ip = get_ip_of_host(only_host)
    return -3 if is_bullshit_ip?(ip)  || @webdb.is_redis_black_ip?(ip)

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

      #puts host
      #pp http_info
      #更新ip
      #@webdb.insert_ip_to_ipaddr(http_info[:ip])

      if domain_is_ip
        @webdb.update_host_to_subdomain(host, domain, '', http_info, exists_host)
      else
        #更新根域名表
        #Sidekiq::Client.enqueue(WhoisTask, domain)

        #更新子域名表
        @webdb.update_host_to_subdomain(host, domain, domain_info.subdomain, http_info, exists_host)
      end

      @webdb.add_user_points(userid, 'host', 1)

      utf8html = http_info[:utf8html]

      if addlinkhosts
        hosts = get_linkes(utf8html).select {|h|
          !@webdb.redis_black_host?(h) && !@webdb.mysql_exists_host(h) && !@webdb.is_redis_black_ip?(get_ip_of_host(host_of_url(h)))
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
      #@webdb.insert_host_to_error_table(host, "#{Socket.gethostname} : http failed! #{http_info[:errstring]}") if http_info[:write_error]
      return -7
    end
  end

end


