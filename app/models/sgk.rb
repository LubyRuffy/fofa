require 'elasticsearch/model'

=begin
model继承的几个方法：

count是获取查询语句对应Elasticsearch::Persistence::Model::Find的count，也就是说是取查询返回数据的个数
  构造的查询语句是: http://127.0.0.1:9200/fofa/subdomain/_search?search_type=count ；
  es_count对应的查询语句是: http://127.0.0.1:9200/fofa/subdomain/_count

search:
  返回的是Elasticsearch::Persistence::Repository::Response::Results: http://www.rubydoc.info/gems/elasticsearch-persistence/Elasticsearch/Persistence/Repository/Response/Results
    totol 返回的总数，results是返回结果数组
  es_search对应的是返回原始数据，json格式：result['hits']['total']
=end
class Sgk < ActiveRecord::Base
  include Elasticsearch::Model

  index_name 'sgk'
  @client = Elasticsearch::Model.client
  @index = index_name

  class << self
    def index
      @index
    end

    def index=(index)
      index_name index
      @index = index_name
    end


    #文档个数
    def es_count(index=nil)
      index ||= @index
      @client.count(index: index)['count']
    rescue
      0
    end

    def search(query_or_payload, options={})
      options.merge!({index: @index, type: @type})
      __elasticsearch__.search(query_or_payload, options)
    end

    #data = Sgk.get_emails('sohu-inc.com')
    def get_emails(domain,maxsize)
      q = {query:     { query_string:  { query: "email:\"#{domain}\"" } }, size: maxsize }
      res = search(q)
      res.map do |s|
        s['_source']['email']
      end
    end

    def alltypes
      result = @client.indices.get_mapping(index: @index).to_hash
      types = result[@index]['mappings'].map{|k,v|
        k
      }
      types_cnt = {}
      types.each{|src|
        cnt = @client.count(index: @index, type: src)['count']
        types_cnt[src] = cnt
      }
      types_cnt
    end
  end
end