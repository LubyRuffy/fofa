#!/usr/bin/env ruby
# encoding: utf-8
require 'domainatrix'
require 'sidekiq'
require 'thread/pool'
require 'script_detector'
require 'whois'
root_path = File.expand_path(File.dirname(__FILE__))
require root_path+"/lrlink.rb"
require root_path+"/webdb2_class.rb"
require root_path+"/httpmodule.rb"


class Uitask
  include HttpModule
  include Lrlink
  include Sidekiq::Worker

  sidekiq_options :queue => :ui_task, :retry => 3, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def initialize(webdb=nil)
    root_path = File.expand_path(File.dirname(__FILE__))

    @@g_webdb ||= webdb
    @@g_webdb ||= WebDb.new(root_path+"/../../../config/database.yml")

    @webdb = @@g_webdb
  end

  def perform(jobid, action, domain)
    @@blackc_coms = ['HICHINA ZHICHENG TECHNOLOGY LTD.', 'MARKMONITOR INC.', 'CHENGDU WEST DIMENSION DIGITAL TECHNOLOGY CO., LTD.',
      'Public Interest Registry', 'ENAME TECHNOLOGY CO., LTD.', 'XIN NET TECHNOLOGY CORPORATION',
      'WEB COMMERCE COMMUNICATIONS LIMITED DBA WEBNIC.CC',
      'Japan Registry Services', 'ENOM, INC.','35 TECHNOLOGY CO., LTD',
      'ASCIO TECHNOLOGIES, INC.', 'GODADDY.COM, LLC', 'NETWORK SOLUTIONS, LLC.', 'CSC CORPORATE DOMAINS, INC.','NAME.COM LLC']
    @@blackc_emails = ['domainadm@hichina.com', 'whoisprivacyprotectionservices.com', 'whois.private.service@gmail.com', 'China NIC']
    addmsg(jobid, 'start dumping...')
    case action
      when 'alldomains'
        domains = [{domain:domain, finished:false}]
        emails = []
        companys = []
        while ( domains.detect{|d| !d[:finished] } || emails.detect{|e| !e[:finished] } )
          if domains.size>200
            puts "max size, now quit..."
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
                  addmsg(jobid, r['ym'])
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

            process_domain[:finished] = true

          end

          #处理emails
          process_email = emails.detect{|e| !e[:finished]}
          if process_email
            puts "========= #{process_email[:email]} =========="
            res = @webdb.queryer.query("select domain from rootdomain where email='#{Mysql2::Client.escape(process_email[:email])}'")
            res.each{ |r|
              found_domain = domains.detect{|d| d[:domain].downcase==r['domain'].downcase}
              unless found_domain
                domains << {domain:r['domain'], finished:false}
                addmsg(jobid, r['domain'])
              end
            }
            process_email[:finished] = true
          end

          #处理companys
          process_company = companys.detect{|c| !c[:finished]}
          if process_company
            puts "========= #{process_company[:company]} =========="
            res = @webdb.queryer.query("select domain from rootdomain where whois_com='#{Mysql2::Client.escape(process_company[:company])}' limit 1000")
            if res.size<1000
              res.each{ |r|
                found_domain = domains.detect{|d| d[:domain].downcase==r['domain'].downcase}
                unless found_domain
                  domains << {domain:r['domain'], finished:false}
                  addmsg(jobid, r['domain'])
                end
              }
            else
              #可能是个域名注册商
              puts "===> bad company name: #{process_company[:company]}"
            end

            res = @webdb.queryer.query("select ym from icp where DWMC='#{Mysql2::Client.escape(process_company[:company])}'")
            res.each{ |r|
              if r['ym']
                found_domain = domains.detect{|d| d[:domain].downcase==r['ym'].downcase}
                unless found_domain
                  domains << {domain:r['ym'], finished:false}
                  addmsg(jobid, r['ym'])
                end
              end
            }

            process_company[:finished] = true
          end
        end

      else
        addmsg(jobid, 'unknown action')
    end
    addmsg(jobid, '<<<finished>>>')

  end

  def addmsg(jobid,msg)
    key = "fofa:task:#{jobid}"
    @webdb.redis.rpush(key,msg)
    @webdb.redis.expire(key, 10*60) #10分钟过期
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

  def perform(rootdomain)
    return if rootdomain.include? '.edu.cn'
    need_update,exist_domain=@webdb.need_update_domain(rootdomain)
    if need_update
      r = Whois.whois(rootdomain)
      email = ''
      email = r.properties[:registrant_contacts].first.email if r.properties[:registrant_contacts] && r.properties[:registrant_contacts].first
      #r.created_on, r.expires_on, r.updated_on
      whois_com = ''
      whois_com = r.registrar.name if r.registrar
      ns_info = r.nameservers.map{|ns| ns.name}.join(',')
      @webdb.db_insert_domain(rootdomain.downcase, r.to_s, whois_com, email, ns_info)
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

  def perform(url)
    add_host_to_webdb(url,false)
  end

  #最上层函数，添加host到数据库
  def add_host_to_webdb(host, force=false, addlinkhosts=true)
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
        Sidekiq::Client.enqueue(WhoisTask, domain)

        #更新子域名表
        @webdb.update_host_to_subdomain(host, domain, domain_info.subdomain, http_info, exists_host)
      end

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


