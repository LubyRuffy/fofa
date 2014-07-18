require 'mysql2'
require 'redis'
require 'digest'
require 'time'
require 'yaml'
#require 'hexdump'

class WebDb
  @mysql = nil
  @redis = nil

  def initialize(cfgfile="./config.yml")
    rails_env = ENV['RAILS_ENV'] || 'development'
    g_config = YAML::load(File.open(cfgfile))
    config = g_config[rails_env]
    begin
      @mysql = Mysql2::Client.new(:host => config['host'], :username => config['username'], :password => config['password'], :database => config['database'], :port => config['port'], :secure_auth => false)
    rescue Mysql2::Error => e
      puts "Mysql::Error"
      puts "Error code: #{e}"
      puts "Error message: #{e.message}"
      exit
    end
    config = config['redis']
    @redis = Redis.new(:host => config['host'])
  end


  private
  def db_query_exists(db, sql)
    db.query(sql).size>0
  end

  def redis_update_checktime(host)
    key = "lct_"+host
    @redis.set(key, Time.now().to_s)
    @redis.expire(key, 60*60*24*7)
  end

  def redis_inc_rootdomain(domain)
    @redis.zincrby('rootdomains',1,domain) #ZREVRANGE rootdomains 0 10 WITHSCORES
  end

  def redis_inc_ip(ip)
    ip = ip.split('.')[0..2].join('.')
    @redis.zincrby('ips',1,ip) #ZREVRANGE ips 0 10 WITHSCORES
  end

  def db_check_subdomain_exists(db, host)
    db_query_exists(db, "select host from subdomain where host='#{Mysql2::Client.escape(host)}'")
  end
  alias db_check_host_exists db_check_subdomain_exists

  def db_check_domain_exists(db, domain)
    db_query_exists(db, "select domain from rootdomain where domainhash='#{Digest::MD5.hexdigest(domain)}'")
  end

  def db_exec(db, sql)
    db.query sql
  end

  def db_insert_domain(db, domain)
    sql = "insert into rootdomain (domain, domainhash) values('#{Mysql2::Client.escape(domain)}', '#{Digest::MD5.hexdigest(domain)}')"
    #puts sql
    db_exec(db, sql)
  end

  def db_insert_host(db, host, domain, subdomain, r)
    title = r[:title]
    title ||= ''
    header = r[:header]
    body = r[:utf8html]
    body ||= ''
    ip = r[:ip]

    sql = "insert into subdomain (host, hosthash, domain, reverse_domain, subdomain, ip, header, title, body, lastchecktime, lastupdatetime)"
    sql += " values('#{Mysql2::Client.escape(host)}', '#{Digest::MD5.hexdigest(host)}', '#{Mysql2::Client.escape(domain)}', '#{Mysql2::Client.escape(domain.reverse)}', "
    sql += "'#{Mysql2::Client.escape(subdomain)}', '#{Mysql2::Client.escape(ip)}', '#{Mysql2::Client.escape(header)}', "
    sql += "'#{Mysql2::Client.escape(title)}', '#{Mysql2::Client.escape(body.force_encoding('UTF-8'))}', now(), now())"
    #puts sql
    db_exec(db, sql)
    redis_update_checktime(host)
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
    sql += ", lastupdatetime=now() where hosthash='#{Digest::MD5.hexdigest(host)}'"
    #puts sql
    db_exec(db, sql)
  end

  def db_check_ip_exists(ip)
    db_query_exists(@mysql, "select ip from ipaddr where iphash='#{Digest::MD5.hexdigest(ip)}'")
  end

  def db_insert_ip(ip)
    sql = "insert into ipaddr (ip, iphash) values('#{Mysql2::Client.escape(ip)}', '#{Digest::MD5.hexdigest(ip)}')"
    #puts sql
    db_exec(@mysql, sql)
  end

  def db_update_subdomain_checktime(host)
    db_exec(@mysql, "update subdomain set lastchecktime=NOW() where hosthash='#{Digest::MD5.hexdigest(host)}'")
    redis_update_checktime(host)
  end

  public
  def mysql
    @mysql
  end

  def redis_exists_host(host)
    key = "lct_"+host
    @redis.exists(key)
  end

  def mysql_exists_host(host)
    db_query_exists(@mysql, "select host from subdomain where host='#{Mysql2::Client.escape(host)}'")
  end

  #update last check time
  def update_subdomain_if_exists(host)
    if db_check_subdomain_exists(@mysql, host)
      db_update_subdomain_checktime(host)
    end
  end

  def insert_ip_to_ipaddr(ip)
    if !db_check_ip_exists(ip)
      db_insert_ip(ip)
    end
  end

  def insert_domain_to_rootdomain(domain)
    if !db_check_domain_exists(@mysql, domain)
      db_insert_domain(@mysql, domain)
    end
  end
  def update_host_to_subdomain( host, domain, subdomain, http_info)
    if db_check_host_exists(@mysql, host)
      db_update_host(@mysql, host, http_info)
    else
      db_insert_host(@mysql, host, domain, subdomain, http_info)
    end
  end

  def insert_host_to_error_table(host, reason)
    sql = "insert into error_host (host, hosthash, reason) values('#{Mysql2::Client.escape(host)}', '#{Digest::MD5.hexdigest(host)}', '#{Mysql2::Client.escape(reason)}') ON DUPLICATE KEY UPDATE reason='#{Mysql2::Client.escape(reason)}'"
    #puts sql
    db_exec(@mysql, sql)
  end

  def need_update_host(host)
    return false if redis_exists_host(host)
    #不存在一条小于90天内的记录就需要更新
    !db_query_exists(@mysql, "select host from subdomain where host='#{Mysql2::Client.escape(host)}' and DATEDIFF(NOW(),lastchecktime)<90")
  end

end


