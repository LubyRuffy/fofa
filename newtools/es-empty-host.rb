#!/usr/bin/env ruby

@root_path = File.expand_path(File.dirname(__FILE__))
#puts @root_path
require 'active_record'
require 'elasticsearch/model'
require 'sidekiq'
require @root_path+"/../config/initializers/sidekiq.rb"
require @root_path+"/../config/initializers/elasticsearch.rb"
require @root_path+"/../app/workers/checkurl.rb"


# Open the "view" of the index
response = Elasticsearch::Model.client.search index: 'fofa',
                                              search_type: 'scan',
                                              scroll: '5m',
                                              body: {
                                                  _source: "_id",
                                                   query: {
                                                       filtered: {
                                                           filter: {
                                                               bool: {
                                                                   must: [
                                                                       {
                                                                           missing: {
                                                                               field: "host"
                                                                           }
                                                                       }
                                                                   ]
                                                               }
                                                           }
                                                       }
                                                   },
                                                   from: 0,
                                                   size: 1000
                                               }

# Call `scroll` until results are empty
total = response['hits']['total'].to_i
finished = 0
while 1
  response = Elasticsearch::Model.client.scroll(scroll_id: response['_scroll_id'], scroll: '5m')
  break if response['hits']['hits'].empty?
  response['hits']['hits'].each { |r|
    CheckUrlWorker.perform_async(r['_id'], true)
    finished += 1
  }
  printf " %d / %d \r", finished, total
end

puts "done"