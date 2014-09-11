#/usr/bin/env ruby
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../../app/workers/module/lrlink.rb"



gem "minitest"

require 'minitest/autorun'
require 'minitest/unit'

class TestLrLink < MiniTest::Unit::TestCase
  include Lrlink

  def setup
  end

  def test_getipofhost
    assert(!get_ip_of_host('www.baidu.com').nil?)
    #assert(get_ip_of_host('www.baidu.com').nil?)
  end

  def test_hostinfo_of_url
    assert_equal(hostinfo_of_url('127.0.0.1:80'), '127.0.0.1')
    assert_equal(hostinfo_of_url('https://127.0.0.1/1/2/3'), 'https://127.0.0.1')
  end

  def test_ip_dec
    assert(ip_dec?('0000314.00000014.0306.000000375'))
    assert(ip_dec?('0x0079.0x000000000000000028.0x0083.00257'))
    assert(ip_dec?('0x0079.0x000000000000000028.0x0083.0x0083'))
    assert(ip_dec?('0000314.00000014.0306.000000375'))
    assert(ip_dec?('0x0079.0x000000000000000028.0x0083'))
    assert(!ip_dec?('111.111.111.111'))
    assert(!ip_dec?('baidu.com'))
  end
end
