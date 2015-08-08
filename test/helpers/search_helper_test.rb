require 'test_helper'
require 'search_helper'
require 'pp'
class SearchHelperTest < ActionView::TestCase
  include SearchHelper
=begin
  test "ElasticProcessor测试" do
    assert_equal "domain:(*360.cn*)", ElasticProcessor.parse('domain="360.cn"')
    assert_equal "( domain:(*360.cn*) && host:(*webscan.360.cn*) )", ElasticProcessor.parse('domain="360.cn" && host="webscan.360.cn"')
    assert_equal "( title:(*PES2016*) && -host:(*bbs*) )", ElasticProcessor.parse('title="PES2016" && host!="bbs"')
    assert_equal "lastupdatetime:([\"2015\\-08\\-05 00\\:00\\:00\" TO *])", ElasticProcessor.parse('lastupdatetime>"2015-08-05 00:00:00"')
    assert_equal "( host:(*webscan.360.cn*) || host:(*wangzhan.360.cn*) )", ElasticProcessor.parse('host="webscan.360.cn" || host="wangzhan.360.cn"')

    assert_equal "( ( ( host:(*webscan.360.cn*) || host:(*wangzhan.360.cn*) ) && title:(*网站安全*) ) && -title:(*检测*) )", ElasticProcessor.parse('((host="webscan.360.cn" || host="wangzhan.360.cn") && title="网站安全") && title!="检测"')
  end
=end
  test "ElasticProcessorBool测试" do
    printf "%s\n", 'location.href=\"homeLogin.action'.query_escape
    assert_equal '{"bool":{"must":[{"term":{"domain":"360.cn"}}]}}', ElasticProcessorBool.parse('domain=="360.cn"')
    assert_equal '{"bool":{"must":[{"query_string":{"query":"body:(\"360.cn\")"}}]}}', ElasticProcessorBool.parse('body=="360.cn"')
    assert_equal '{"bool":{"must":[{"wildcard":{"domain":"*360.cn*"}}]}}', ElasticProcessorBool.parse('domain="360.cn"')
    assert_equal '{"bool":{"must":[{"wildcard":{"title":"* - 融360*"}}]}}', ElasticProcessorBool.parse('title=" - 融360"')
    assert_equal '{"bool":{"must":[{"query_string":{"query":"body:(\"财富说 - 年轻人的银行\")"}}]}}', ElasticProcessorBool.parse('body="财富说 - 年轻人的银行"')

    assert_equal '{"bool":{"must_not":[{"wildcard":{"domain":"*360.cn*"}}]}}', ElasticProcessorBool.parse('domain!="360.cn"')

    assert_equal '{"bool":{"should":[{"term":{"domain":"360.cn"}},{"term":{"domain":"baidu.com"}}]}}', ElasticProcessorBool.parse('domain=="360.cn" || domain=="baidu.com"')
    assert_equal '{"bool":{"must":[{"term":{"domain":"360.cn"}},{"term":{"domain":"baidu.com"}}]}}', ElasticProcessorBool.parse('domain=="360.cn" && domain=="baidu.com"')

    assert_equal '{"bool":{"must":[{"term":{"domain":"360.cn"}},{"bool":{"must_not":[{"wildcard":{"host":"*webscan.360.cn*"}}]}}]}}', ElasticProcessorBool.parse('domain=="360.cn" && host!="webscan.360.cn"')

    assert_equal '{"bool":{"should":[{"term":{"title":"金龙卡金融化一卡通网站查询子系统"}},{"query_string":{"query":"body:(\"location.href=\"homeLogin.action\")"}}]}}', ElasticProcessorBool.parse('title=="金龙卡金融化一卡通网站查询子系统" || body="location.href=\"homeLogin.action"')
  end
end
