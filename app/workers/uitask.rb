
require File.join(FOFA_ROOT_PATH, 'workers', 'httpmodule.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'lrlink.rb')
require File.join(FOFA_ROOT_PATH, 'workers', 'fofadb.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'subdomain.rb')
require File.join(FOFA_ROOT_PATH, 'models', 'icp.rb')

def getallhosts(domain, maxsize)
  black_host = [ /\d+\.qzone\.qq\.com/i,
                 /\d+\.qzone\.com/i,
                 /\d+\.foxmail\.com/i,
                 /\d+\.qq.qzone.com/i,
                 /\d+qq.qzone.com/i, ]
  Subdomain.get_hosts_of_domain(domain.downcase, maxsize).each{ |r|
    unless black_host.find{|b| r=~b }
      yield(r)
    end
  }
end

def getallips(host,maxsize=1000)
  Subdomain.get_ips_of_host(host,maxsize)
end

def getalldomains(domain, maxsize)
  blackc_coms ||= ['HICHINA ZHICHENG TECHNOLOGY LTD.', 'MARKMONITOR INC.', 'CHENGDU WEST DIMENSION DIGITAL TECHNOLOGY CO., LTD.',
                     'Public Interest Registry', 'ENAME TECHNOLOGY CO., LTD.', 'XIN NET TECHNOLOGY CORPORATION',
                     'WEB COMMERCE COMMUNICATIONS LIMITED DBA WEBNIC.CC',
                     'Japan Registry Services', 'ENOM, INC.','35 TECHNOLOGY CO., LTD',
                     'ASCIO TECHNOLOGIES, INC.', 'GODADDY.COM, LLC', 'NETWORK SOLUTIONS, LLC.', 'CSC CORPORATE DOMAINS, INC.','NAME.COM LLC']
  blackc_emails ||= ['domainadm@hichina.com', 'whoisprivacyprotectionservices.com', 'whois.private.service@gmail.com', 'China NIC']

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
      res = Icp.find_by_sql("select ym from icp where DWMC=(select DWMC from icp where ym='#{Mysql2::Client.escape(process_domain[:domain])}' limit 1)")
      res.each{ |r|
        if r['ym']
          found_domain = domains.detect{|d| d[:domain].downcase==r['ym'].downcase}
          unless found_domain
            domains << {domain:r['ym'], finished:false}
            yield(r['ym'])
          end
        end
      }

      res = Icp.find_by_sql("select DWMC from icp where ym='#{Mysql2::Client.escape(process_domain[:domain])}' and DWXZ!='个人'")
      res.each{ |r|
        if r['DWMC']
          found_company = companys.detect{|d| d[:company].downcase==r['DWMC'].downcase}
          unless found_company
            unless blackc_coms.detect{|c| c && r['DWMC'].include?(c)}
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
              unless blackc_coms.detect{|c| c && r['whois_com'].include?(c)}
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
              unless blackc_emails.detect{|e| e && email.include?(e)}
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
      res = Icp.find_by_sql("select ym,SITE_URL from icp where DWMC='#{Mysql2::Client.escape(process_company[:company])}'")
      res.each{ |r|
        tmp_domains = r['SITE_URL']+';'+r['ym']
        tmp_domains = tmp_domains.downcase.split(';').map{|host|
          domain_info = get_domain_info_by_host(hostinfo_of_url(host))
          domain = domain_info.domain+'.'+domain_info.public_suffix
          found_domain = domains.detect{|d| d[:domain].downcase==domain.downcase}
          unless found_domain
            domains << {domain:domain, finished:false}
            yield(domain)
          end
        }
      }

      process_company[:finished] = true
    end
  end
end

class Uitask
  include HttpModule
  include Lrlink
  include Sidekiq::Worker

  sidekiq_options :queue => :ui_task, :retry => 1, :backtrace => true#, :unique => true, :unique_job_expiration => 120 * 60 # 2 hours

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def initialize()
    Sidekiq.redis{|redis|
      @@redis ||= redis
    }

  end

  def perform(jobid, action, domain, maxsize=200)
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
    key = "task:#{jobid}"
    @@redis.rpush(key, msg)
    @@redis.expire(key, 2*60) #2分钟过期
  end

end
