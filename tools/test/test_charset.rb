#/usr/bin/env ruby
@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../../app/jobs/module/httpmodule.rb"

include HttpModule

gem "minitest"
require 'minitest/unit'
require 'minitest/autorun'

class TestMeme < MiniTest::Unit::TestCase

  def setup
  end

  def test_get_utf8
    http = get_web_content 'www.zaren.hu'
    http[:utf8html] = get_utf8 http[:html] if http[:html] and http[:html].size > 2
    assert(http[:utf8html].valid_encoding?)

    http = get_web_content 'www.vpslm.sk'
    http[:utf8html] = get_utf8 http[:html] if http[:html] and http[:html].size > 2
    assert(http[:utf8html].valid_encoding?)
  end
end
