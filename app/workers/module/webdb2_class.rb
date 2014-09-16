require 'mysql2'
require 'redis'
require 'digest'
require 'time'
require 'yaml'
require 'thread'
#require 'celluloid/autostart'
#require 'hexdump'

#thread-safe when use thread/pool
class MysqlQueryer
  #include Celluloid
  @@semaphore ||= Mutex.new
  attr_accessor :mysql
  def initialize(mysql, mysql_write=nil)
    @@semaphore.synchronize {
      @@mysql ||= mysql
      @@mysql_write ||= mysql_write
      @@mysql_write ||= mysql
    }
  end

  def query(sql)
    @@semaphore.synchronize {
      @@mysql.query sql
    }
  end

  def exec(sql)
    @@semaphore.synchronize {
      @@mysql_write.query sql
    }
  end
end

class WebDb
  @@semaphore ||= Mutex.new
  def redis
    return @@redis
  end

  def queryer
    return @@queryer
  end

  def initialize(cfgfile="./config.yml")
    begin
      @@semaphore.synchronize {
        rails_env = ENV['RAILS_ENV'] || 'development'
        g_config = YAML::load(File.open(cfgfile))
        config = g_config[rails_env]
        @@mysql ||= Mysql2::Client.new(:host => config['host'], :username => config['username'],
                                       :password => config['password'], :database => config['database'],
                                       :port => config['port'], :secure_auth => config['secure_auth'],
                                       :encoding => 'utf8', :reconnect => true)
        mysql_write_config = config['mysql_write']
        if mysql_write_config
          @@mysql_write ||= Mysql2::Client.new(:host => mysql_write_config['host'], :username => mysql_write_config['username'],
                                       :password => mysql_write_config['password'], :database => mysql_write_config['database'],
                                       :port => mysql_write_config['port'], :secure_auth => mysql_write_config['secure_auth'],
                                       :encoding => 'utf8', :reconnect => true)
        else
          @@mysql_write = @@mysql
        end
        @@queryer ||= MysqlQueryer.new(@@mysql, @@mysql_write)

        config = config['redis']
        @@redis ||= Redis.new(url: "redis://#{config['host']}:#{config['port']}/#{config['db']}")
      }
    rescue Mysql2::Error => e
      puts "Mysql::Error"
      puts "Error code: #{e}"
      puts "Error message: #{e.message}"
      exit
    end

  end

  def is_redis_black_domain?(domain)
    return true unless domain
    @@redis.sismember('fofa:black_domains', domain)
  end

  def is_redis_black_ip?(ip)
    return true unless ip
    ip = ip.split('.')[0..2].join('.')
    @@redis.sismember('fofa:black_ips', ip)
  end

  def redis_has_host?(host)
    return true unless host
    @@redis.sismember('fofa:hosts', host)
  end

  def redis_black_host?(host)
    return true unless host
    @@redis.sismember('fofa:black_hosts', host)
  end

  def redis_inc_failed_host(host)
    @@redis.sadd('fofa:black_hosts', host) if @@redis.zincrby('fofa:failedhosts',1,host)>10
  end

  def redis
    @@redis
  end

  private
  def db_query_exists(db, sql)
    @@queryer.query(sql).size>0
  end

  def redis_update_checktime(host)
    key = "lct_"+host
    @@redis.set(key, Time.now().to_s)
    @@redis.expire(key, 60*60*24*7)
  end

  def redis_inc_rootdomain(domain)
    @@redis.sadd('fofa:black_domains', domain) if @@redis.zincrby('fofa:rootdomains',1,domain)>200
  end

  def redis_add_host(host)
    @@redis.sadd('fofa:hosts', host)
  end

  def redis_inc_ip(ip)
    ip = ip.split('.')[0..2].join('.')
    @@redis.sadd('fofa:black_ips', ip) if @@redis.zincrby('fofa:ips',1,ip)>200
  end


  def db_check_subdomain_exists(db, host)
    db_query_exists(db, "select host from subdomain where host='#{Mysql2::Client.escape(host)}'")
  end
  alias db_check_host_exists db_check_subdomain_exists

  def db_check_domain_exists(db, domain)
    db_query_exists(db, "select domain from rootdomain where domain='#{Mysql2::Client.escape(domain)}'")
  end

  def db_exec(db, sql)
    @@queryer.exec sql
  end

  def db_insert_domain(db, domain)
    sql = "insert into rootdomain (domain, domainhash) values('#{Mysql2::Client.escape(domain.downcase)}', '#{Digest::MD5.hexdigest(domain)}')"
    #puts sql
    db_exec(db, sql) rescue db_exec(db, "update rootdomain set domain='#{Mysql2::Client.escape(domain.downcase)}', domainhash='#{Digest::MD5.hexdigest(domain.downcase)}' where domain='#{Mysql2::Client.escape(domain)}'")
  end

  def db_insert_host(db, host, domain, subdomain, r)
    title = r[:title]
    title ||= ''
    header = r[:header]
    body = r[:utf8html]
    body ||= ''
    ip = r[:ip]

    sql = "insert into subdomain (host, domain, reverse_domain, subdomain, ip, header, title, body, lastchecktime, lastupdatetime)"
    sql += " values('#{Mysql2::Client.escape(host)}', '#{Mysql2::Client.escape(domain)}', '#{Mysql2::Client.escape(domain.reverse)}', "
    sql += "'#{Mysql2::Client.escape(subdomain)}', '#{Mysql2::Client.escape(ip)}', '#{Mysql2::Client.escape(header)}', "
    sql += "'#{Mysql2::Client.escape(title)}', '#{Mysql2::Client.escape(body.force_encoding('UTF-8'))}', now(), now())"
    #puts sql
    db_exec(db, sql)
    #redis_update_checktime(host)
    redis_add_host(host)
    redis_inc_rootdomain(domain)
    redis_inc_ip(ip)
  end

  def db_update_host(db, host, r)
    title = r[:title]
    title ||= ''
    header = r[:header]
    body = r[:utf8html]
    body ||= ''
    ip = r[:ip]
    sql = "update subdomain set ip='#{Mysql2::Client.escape(ip)}'"
    sql += ", header='#{Mysql2::Client.escape(header)}'"
    sql += ", title='#{Mysql2::Client.escape(title)}'"
    sql += ", body='#{Mysql2::Client.escape(body.force_encoding('UTF-8'))}'"
    sql += ", lastupdatetime=now() where host='#{Mysql2::Client.escape(host)}'"
    #puts sql
    db_exec(db, sql)
  end

  def db_check_ip_exists(ip)
    db_query_exists(@@mysql, "select ip from ipaddr where iphash='#{Digest::MD5.hexdigest(ip)}'")
  end

  def db_insert_ip(ip)
    sql = "insert into ipaddr (ip, iphash) values('#{Mysql2::Client.escape(ip)}', '#{Digest::MD5.hexdigest(ip)}')"
    #puts sql
    db_exec(@@mysql, sql)
  end

  def db_update_subdomain_checktime(host)
    db_exec(@@mysql, "update subdomain set lastchecktime=NOW() where host='#{Mysql2::Client.escape(host)}'")
    #redis_update_checktime(host)
  end

  public
  def mysql
    @@mysql
  end

  def redis_exists_host(host)
    key = "lct_"+host
    @@redis.exists(key)
  end

  def mysql_exists_host(host)
    db_query_exists(@@mysql, "select host from subdomain where host='#{Mysql2::Client.escape(host)}'")
  end

  #update last check time
  def update_subdomain_if_exists(host, host_exists=false)
    if host_exists || db_check_subdomain_exists(@@mysql, host)
      db_update_subdomain_checktime(host)
    end
  end

  def insert_ip_to_ipaddr(ip)
    if !db_check_ip_exists(ip)
      db_insert_ip(ip)
    end
  end

  def insert_domain_to_rootdomain(domain, host_exists=false)
    unless host_exists || db_check_domain_exists(@@mysql, domain)
      db_insert_domain(@@mysql, domain)
    end
  end
  def update_host_to_subdomain( host, domain, subdomain, http_info, host_exists=false)
    if host_exists || db_check_host_exists(@@mysql, host)
      db_update_host(@@mysql, host, http_info)
    else
      db_insert_host(@@mysql, host, domain, subdomain, http_info)
    end
  end

  def insert_host_to_error_table(host, reason)
    sql = "insert into error_host (host, reason) values('#{Mysql2::Client.escape(host)}', '#{Mysql2::Client.escape(reason)}') ON DUPLICATE KEY UPDATE reason='#{Mysql2::Client.escape(reason)}'"
    #puts sql
    db_exec(@@mysql, sql)
  end

  def need_update_host(host)
    #return false if redis_has_host?(host)

    #不存在一条小于90天内的记录就需要更新
    r = @@queryer.query("select host,lastchecktime from subdomain where host='#{Mysql2::Client.escape(host)}'")
    @need_update = false
    @exist_host = false
    if r.size>0
      @exist_host = true
      diff_time = (Time.now - r.first['lastchecktime']).to_i
      if  (diff_time/86400)>90
        @need_update = true
      else
       @need_update = false
      end
    else
      @need_update = true
    end
    [@need_update, @exist_host]
  end

end


