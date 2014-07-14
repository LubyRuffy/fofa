@root_path = File.expand_path(File.dirname(__FILE__))
require @root_path+"/../../app/jobs/module/httpmodule.rb"
require "test/unit"

class TestHttp< Test::Unit::TestCase
  include HttpModule

  def test_getutf8()
    http = get_web_content 'www.zaren.hu'
    http[:utf8html] = get_utf8 http[:html] if http[:html] and http[:html].size > 2
    assert(http[:utf8html].valid_encoding?)
  end
end
