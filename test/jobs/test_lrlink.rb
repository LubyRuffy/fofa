#/usr/bin/env ruby
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../../app/jobs/module/lrlink.rb"

include Lrlink

gem "minitest"
require 'minitest/unit'
require 'minitest/autorun'

class TestLrLink < MiniTest::Unit::TestCase

  def setup
  end

  def test_getipofhost
    assert(!get_ip_of_host('www.baidu.com').nil?)
    assert(get_ip_of_host('www.baidu.com').nil?)
  end
end
