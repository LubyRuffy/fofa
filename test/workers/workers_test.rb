require 'test_helper'

root_path = File.expand_path(File.dirname(__FILE__))
($LOAD_PATH << root_path << File.join(root_path, 'lib') << File.join(root_path, 'workers')).uniq!
require 'checkurl'

class CheckUrlWorker
  @@just_for_test = true
end

class WorkersTest < ActiveSupport::TestCase

  test '非法host测试' do
    assert_equal CheckUrlWorker.new.perform('',false,false,0), ERROR_INVALID_HOST
    v = checkurl('nevercouldexists.qq.com',false,false,0){ |host, domain, subdomain, addlinkhosts, userid|
      process_url(host, domain, subdomain, addlinkhosts, userid){|host, domain, subdomain, http_info, addlinkhosts, userid|
      }
    }
    assert_equal v, ERROR_HOST_DNS
  end

  test '非法ip测试' do
    assert_equal CheckUrlWorker.new.perform('0000315.00000024.0206.000000275',false,false,0), ERROR_INVALID_IP
    assert_equal CheckUrlWorker.new.perform('0x0079.0x000000000000000028.0x0083.00257',false,false,0), ERROR_INVALID_IP
  end

  test '加黑ip测试（ip网段）' do
    v = checkurl('0.0.0.0',false,false,0){ |host, domain, subdomain, addlinkhosts, userid|
      process_url(host, domain, subdomain, addlinkhosts, userid){|host, domain, subdomain, http_info, addlinkhosts, userid|
      }
    }
    assert_equal v, ERROR_BLACK_IP

    v = checkurl('127.0.0.1',false,false,0){ |host, domain, subdomain, addlinkhosts, userid|
      process_url(host, domain, subdomain, addlinkhosts, userid){|host, domain, subdomain, http_info, addlinkhosts, userid|
      }
    }
    assert_equal v, ERROR_BLACK_IP

    Test_IP_NET = '1.1.1'
    FofaDB.redis.srem('fofa:black_ips', Test_IP_NET)
    assert_not FofaDB.redis.sismember('fofa:black_ips', Test_IP_NET)
    FofaDB.redis.sadd('fofa:black_ips', Test_IP_NET)
    v = checkurl('1.1.1.1',false,false,0){ |host, domain, subdomain, addlinkhosts, userid|
      process_url(host, domain, subdomain, addlinkhosts, userid){|host, domain, subdomain, http_info, addlinkhosts, userid|
      }
    }
    assert_equal v, ERROR_BLACK_IP
    FofaDB.redis.srem('fofa:black_ips', Test_IP_NET)
  end

  test '加黑domain测试(超过阈值个子域名的根域名)' do
    FofaDB.redis.srem('fofa:black_domains', 'for-fofa-test-black-domain.com')
    assert_not FofaDB.redis.sismember('fofa:black_domains', 'for-fofa-test-black-domain.com')
    FofaDB.redis.sadd('fofa:black_domains', 'for-fofa-test-black-domain.com')
    assert_equal CheckUrlWorker.new.perform('www.for-fofa-test-black-domain.com',false,false,0), ERROR_BLACK_DOMAIN
    FofaDB.redis.srem('fofa:black_domains', 'for-fofa-test-black-domain.com')
  end

  test '加黑host测试(20次无法访问的网站)' do
    FofaDB.redis.srem('fofa:black_hosts', 'www.for-fofa-test-black-domain.com')
    assert_not FofaDB.redis.sismember('fofa:black_hosts', 'www.for-fofa-test-black-domain.com')
    FofaDB.redis.sadd('fofa:black_hosts', 'www.for-fofa-test-black-domain.com')
    assert_equal CheckUrlWorker.new.perform('www.for-fofa-test-black-domain.com',false,false,0), ERROR_BLACK_HOST
    FofaDB.redis.srem('fofa:black_hosts', 'www.for-fofa-test-black-domain.com')
  end

  test '90天更新机制测试' do
    Subdomain.es_delete('just-for-test.fofa.so') if Subdomain.es_exists?('just-for-test.fofa.so')
    Subdomain.es_insert('just-for-test.fofa.so', 'fofa.so','just-for-test', {'lastchecktime'=>Time.now.strftime("%Y-%m-%d %H:%M:%S")}, true)
    assert_equal CheckUrlWorker.new.perform('just-for-test.fofa.so',false,false,0), HOST_NONEED_UPDATE
    Subdomain.es_insert('just-for-test.fofa.so', 'fofa.so','www', {'lastchecktime'=>(Time.now - 91*24*60*60).strftime("%Y-%m-%d %H:%M:%S")}, true)
    assert_equal CheckUrlWorker.new.perform('just-for-test.fofa.so',false,false,0).size, 24
    Subdomain.es_delete('just-for-test.fofa.so')
  end

  test 'invalid_ip机制测试' do
    RealtimeprocessWorker.new.perform('webscan.360.cn')
    RealtimeprocessWorker.new.perform('abc.360.cn')
  end
end
