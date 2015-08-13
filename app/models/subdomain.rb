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
class Subdomain < ActiveRecord::Base
  include Elasticsearch::Model

  index_name 'fofa'
  document_type 'subdomain'
  @client = Elasticsearch::Model.client
  @index = index_name
  @type = document_type

  class << self
    def index
      @index
    end

    def index=(index)
      index_name index
      @index = index_name
    end

    def es_size
      @client.count(index: @index, type: @type)['count']
    end

    alias :es_length :es_size


    #文档个数
    def es_count(index=nil)
      index ||= @index
      @client.count(index: index, type: @type)['count']
    rescue
      0
    end

=begin
    #查找，系统自带的更好用
    def es_search(query)
      @client.search index: @index, type: @type, q: query
    rescue
      nil
    end
=end

    #是否存在某条文档
    def es_exists?(host)
      v = @client.exists index: @index, type: @type, id: host
      puts v
      v
    end

    #按id查找document
    def es_get(host,fields=nil)
      query = {index: @index, type: @type, id: host}
      query[:fields] = fields if fields
      @client.get query
    rescue
      nil
    end

    def es_delete(host)
      @client.delete index: @index, type: @type, id: host
    end

    def prepare_records(res)
      records = []
      res.each{|r|
        title = r['title']
        title ||= ''
        header = r['header']
        body = r['utf8html']
        body ||= ''
        ip = r['ip']
        host = r['host']
        records << { index:  { _index: @index, _type: @type, _id: host, data: {
            host: host,
            domain: r['domain'],
            reverse_domain: r['domain'].reverse,
            subdomain: r['subdomain'],
            ip: ip,
            header: header,
            title: title,
            body: body.force_encoding('UTF-8'),
            lastchecktime: r['lastchecktime'] || Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            lastupdatetime: r['lastupdatetime'] || Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        } } }
      }
      records
    end

    def es_bulk_insert(res, refresh=false)
      records = prepare_records(res)
      @client.bulk body: records, refresh: refresh
    end

    #插入文档

    def es_insert(host, domain, subdomain, r, refresh=false)
      title = r['title']
      title ||= ''
      header = r['header']
      body = r['utf8html']
      body ||= ''
      ip = r['ip']

      @client.index index: @index, type: @type,
                    id: host,
                    body: {
                        host: host,
                        domain: domain,
                        reverse_domain: domain.reverse,
                        subdomain: subdomain,
                        ip: ip,
                        header: header,
                        title: title,
                        body: body.force_encoding('UTF-8'),
                        lastchecktime: r['lastchecktime'] || Time.now.strftime("%Y-%m-%d %H:%M:%S"),
                        lastupdatetime: r['lastupdatetime'] || Time.now.strftime("%Y-%m-%d %H:%M:%S"),
                    }, refresh: refresh
    end

    def update_checktime_of_host(host, refresh=false)
      @client.update index: @index, type: @type,
                     id: host,
                     body: {
                         doc: {
                             lastchecktime: Time.now.strftime("%Y-%m-%d %H:%M:%S")
                         }
                     }, refresh: refresh
    end

    def get_hosts_of_domain(domain, count=100)
      @query_l = %Q|
          {
              "filtered": {
                  "filter": {
                      "query": {
                          "term": {
                              "domain": "#{domain}"
                          }
                      }
                  }
              }
          }|
      result = __elasticsearch__.search({_source: ['host'],
                                          query: JSON.parse(@query_l),
                                          size: count}, {index: @index, type: @type} )
      result.map{|r| r.host}
    end

    def get_ips_of_domain(domain, maxsize=1000)
      query=%Q|
{
  "_source": [
    "host",
    "ip"
  ],
  "aggs": {
    "ips_of_domain": {
      "filter": {
        "term": {
          "domain": "#{domain.downcase}"
        }
      },
      "aggs": {
        "net": {
          "terms": {
            "script_file": "ipsubnet",
            "size": 1000
          },
          "aggs": {
            "ips": {
              "terms": {
                "field": "ip",
                "size": 256
              },
              "aggs": {
                "hosts": {
                  "terms": {
                    "field": "host",
                    "size": 100,
                    "order": {
                      "url_size": "asc"
                    }
                  },
                  "aggs": {
                    "url_size": {
                      "min": {
                        "script_file": "hostsize"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  "size": 0
}
|
      ipsts = []
      aggs = __elasticsearch__.search(JSON.parse(query)).response
      aggs["aggregations"]["ips_of_domain"]["net"]["buckets"].each{|netagg|
        ipnet = netagg['key']
        hosts = []
        ips = []
        netipcnt = 0
        netagg['ips']["buckets"].each{|ipagg|
          netipcnt += 1
          ips << ipagg['key_as_string']
          ipagg['hosts']["buckets"].each{|hostagg|
            hosts << hostagg['key']
          }
        }
        ipsts << [ipnet,hosts.join(','),ips.join(','),netipcnt]
      }
      ipsts
    end

    def get_ips_of_host(host, count=100)
      doc = es_get(host.downcase)
      doc['_source']['ip'].split(',')
    end

    def search(query_or_payload, options={})
      options.merge!({index: @index, type: @type})
      __elasticsearch__.search(query_or_payload, options)
    end
  end
end