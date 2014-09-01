#/usr/bin/env ruby
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../../app/workers/module/lrlink.rb"

include Lrlink

gem "minitest"

require 'minitest/autorun'
require 'minitest/unit'

class TestLrLink < MiniTest::Unit::TestCase

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
end
