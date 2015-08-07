#!/usr/bin/env ruby

@root_path = File.expand_path(File.dirname(__FILE__))
#puts @root_path
require 'yaml'
require 'sidekiq'
require 'elasticsearch/model'
require @root_path+"/../config/initializers/elasticsearch.rb"


# Open the "view" of the index
response = Elasticsearch::Model.client.search index: 'fofa',
                                              type: 'subdomain',
                                              search_type: 'scan',
                                              scroll: '10m',
                                              body: {
                                                  _source: "header",
                                                  query: {
                                                      constant_score: {
                                                          filter: {
                                                              missing: {
                                                                  field: "header_ok"
                                                              }
                                                          }
                                                      }
                                                  },
                                                  size: 1000
                                              }

# Call `scroll` until results are empty
total = response['hits']['total'].to_i
finished = 0
while 1
  response = Elasticsearch::Model.client.scroll(scroll_id: response['_scroll_id'], scroll: '5m')
  break if response['hits']['hits'].empty?

  bulk = []
  response['hits']['hits'].each { |doc|
    bulk << {update: {_index: 'fofa', _type: 'subdomain', _id: doc['_id'], data: {doc: {header: doc['_source']['header']}}}}
    finished += 1
  }

  unless bulk.empty?
    #puts bulk
    Elasticsearch::Model.client.bulk body: bulk
  end

  printf " %d / %d \r", finished, total
end

puts "done"