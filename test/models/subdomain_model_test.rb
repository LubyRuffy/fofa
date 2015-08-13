require 'test_helper'
#require 'subdomain'

#打开类仅仅用于测试
class Subdomain
  class << self
    attr_accessor :client #仅仅用于测试，请勿实际调用
  end
end

class SubdomainModelTest < ActiveSupport::TestCase
  test "添加删除文档测试" do
    Subdomain.index = 'just_test_index'
    Subdomain.es_delete('test.com') if Subdomain.es_exists?('test.com')
    assert_nil Subdomain.es_get('test.com')
    Subdomain.es_insert('test.com', 'test.com','', {})
    assert Subdomain.es_exists?('test.com')
    assert_not_nil Subdomain.es_get('test.com')
    a = Subdomain.es_get('test.com')['_source']
    assert_equal(a['lastupdatetime'], a['lastchecktime'])
    Subdomain.es_delete('test.com')
    assert_nil Subdomain.es_get('test.com')
  end

  test "更新lastchecktime测试" do
    Subdomain.index = 'just_test_index'
    Subdomain.es_delete('test.com') if Subdomain.es_exists?('test.com')
    assert_nil Subdomain.es_get('test.com')
    Subdomain.es_insert('test.com', 'test.com','', {})
    assert Subdomain.es_exists?('test.com')
    sleep 1
    Subdomain.update_checktime_of_host('test.com')
    a = Subdomain.es_get('test.com')['_source']
    assert_not_equal(a['lastupdatetime'], a['lastchecktime'])
    Subdomain.es_delete('test.com')
  end

  test '更新文档测试' do
    Subdomain.index = 'just_test_index'
    Subdomain.es_delete('test.com') if Subdomain.es_exists?('test.com')
    assert_nil Subdomain.es_get('test.com')
    Subdomain.es_insert('test.com', 'test.com','', {'title'=>'title1', 'utf8html'=>'body1', 'ip'=>'ip1', 'header'=>'header1'}, true)
    a = Subdomain.es_get('test.com')['_source']
    assert_not_nil a
    assert_equal a['title'], 'title1'
    assert_equal a['body'], 'body1'
    assert_equal a['ip'], 'ip1'
    assert_equal a['header'], 'header1'

    Subdomain.es_insert('test.com', 'test.com','', {'title'=>'title2', 'utf8html'=>'body2', 'ip'=>'ip2', 'header'=>'header2'}, true)
    a = Subdomain.es_get('test.com')['_source']
    assert_not_nil a
    assert_equal a['title'], 'title2'
    assert_equal a['body'], 'body2'
    assert_equal a['ip'], 'ip2'
    assert_equal a['header'], 'header2'

    Subdomain.es_delete('test.com')
  end

  test '计数测试' do
    Subdomain.index = 'just_test_index'
    Subdomain.client.indices.delete(index: Subdomain.index) if Subdomain.client.indices.exists?(index: Subdomain.index)
    assert_equal Subdomain.es_count, 0
    assert_not Subdomain.client.indices.exists?(index: Subdomain.index)
    Subdomain.es_insert('1.test.com', 'test.com','', {'title'=>'title1', 'utf8html'=>'body1', 'ip'=>'ip1', 'header'=>'header1'}, true)
    assert (Subdomain.client.indices.exists?(index: Subdomain.index))
    assert_equal(Subdomain.es_count, 1)
    Subdomain.es_insert('2.test.com', 'test.com','', {'title'=>'title1', 'utf8html'=>'body1', 'ip'=>'ip1', 'header'=>'header1'}, true)
    assert_equal(Subdomain.es_count, 2)
    Subdomain.client.indices.delete(index: Subdomain.index)
    assert_equal(Subdomain.es_count, 0)
  end

  test '查找测试' do
    Subdomain.index = 'just_test_index'
    Subdomain.client.indices.delete(index: Subdomain.index) if Subdomain.client.indices.exists?(index: Subdomain.index)
    assert_equal(Subdomain.es_count, 0)
    Subdomain.es_insert('1.test.com', 'test.com','', {'title'=>'title1', 'utf8html'=>'body1', 'ip'=>'ip1', 'header'=>'header1'}, true)
    Subdomain.es_insert('2.test.com', 'test.com','', {'title'=>'title1', 'utf8html'=>'body1', 'ip'=>'ip1', 'header'=>'header1'}, true)
    assert_equal(Subdomain.es_count, 2)
    result = Subdomain.search('title:title1')
    assert_equal(result.size, 2)
    result = Subdomain.search('title:title2')
    assert_equal(result.size, 0)
  end

  test '批量操作测试' do
    Subdomain.index = 'just_test_index'
    Subdomain.client.indices.delete(index: Subdomain.index) if Subdomain.client.indices.exists?(index: Subdomain.index)
    assert_equal(Subdomain.es_count, 0)
    Subdomain.es_bulk_insert([
                                 {'title'=>'title1', 'utf8html'=>'body1', 'ip'=>'ip1', 'header'=>'header1', 'host'=>'1.test.com', 'domain'=>'test.com', 'subdomain'=>'1'},
                                 {'title'=>'title1', 'utf8html'=>'body2', 'ip'=>'ip2', 'header'=>'header2', 'host'=>'2.test.com', 'domain'=>'test.com', 'subdomain'=>'2'}
                             ], true)
    result = Subdomain.search('title:title1')
    assert_equal(result.size, 2)
    result = Subdomain.search('title:title2')
    assert_equal(result.size, 0)
  end

  test '获取域名测试' do
    Subdomain.index = 'just_test_index'
    Subdomain.client.indices.delete(index: Subdomain.index) if Subdomain.client.indices.exists?(index: Subdomain.index)
    assert_equal(Subdomain.es_count, 0)
    Subdomain.es_bulk_insert([
                                 {'title'=>'title1', 'utf8html'=>'body1', 'ip'=>'1.1.1.1', 'header'=>'header1', 'host'=>'1.test.com', 'domain'=>'test.com', 'subdomain'=>'1'},
                                 {'title'=>'title1', 'utf8html'=>'body2', 'ip'=>'2.2.2.2', 'header'=>'header2', 'host'=>'2.test.com', 'domain'=>'test.com', 'subdomain'=>'2'}
                             ], true)
    result = Subdomain.get_hosts_of_domain('test.com')
    #puts result
    assert_equal(result.size, 2)
    result = Subdomain.get_ips_of_host('1.test.com')
    assert_equal(result[0], '1.1.1.1')
  end
end
