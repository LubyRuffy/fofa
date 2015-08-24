#!/usr/bin/env ruby

@root_path = File.expand_path(File.dirname(__FILE__))
require 'yaml'
require 'awesome_print'
require 'elasticsearch/model'

class Sidekiq
  def self.server?
    false
  end
end
require @root_path+"/../config/initializers/elasticsearch.rb"

class RdnsBulkIndex
  def initialize(file='rdns.txt', startline=0)
    @file = file
    @startline = startline
    if !File.exist?(@file) && $test_data.size<1
      puts "[ERROR] File not exists, quit..."
      exit
    end
    @client = Elasticsearch::Model.client
    @index = 'networks'
    @type = 'rdns'
  end

  def create_mapping
    unless @client.indices.exists_type(index: @index, type: @type)
      @client.indices.create(
          index: @index,
          type: @type,
          body: {
              settings: {
                  index: {
                      analysis: {
                          char_filter: {
                              dot_split_filter: {
                                  type: "pattern_replace",
                                  pattern: "\\.",
                                  replacement: " "
                              }
                          },
                          analyzer: {
                              dot_split_analyzer: {
                                  tokenizer: "standard",
                                  char_filter: [
                                      "dot_split_filter"
                                  ]
                              }
                          }
                      }
                  }
              },
              mappings: {
                  rdns: {
                      properties: {
                          ip: {
                              type: 'multi_field',
                              fields: {
                                  ip: {
                                      type: 'ip'
                                  },
                                  ipraw: {
                                      type: "string",
                                      analyzer: "dot_split_analyzer"
                                  },
                                  ipstr: {
                                      type: "string",
                                      index: "not_analyzed"
                                  }
                              }
                          },
                          name: {
                              type: 'string',
                              analyzer: "dot_split_analyzer"
                          },

                      }
                  }
              }
          }
      )
    else
      puts "type exists, no changes!"
    end
  end

  def prepare_records(res)
    records = []
    res.each { |r|
      r.strip!
      ip, name = r.split(',')
      records << {
          index: {
              _index: @index,
              _type: @type,
              _id: ip,
              data: {
                  ip: ip,
                  name: name
              }
          }
      }
    }
    records
  end

  def es_bulk_insert(res, refresh=false)
    records = prepare_records(res)
    @client.bulk body: records, refresh: refresh
  end

  def run
    create_mapping

    arr = []
    i = 0
    File.open(@file).each_line { |line|
      if i >= @startline
        arr << line
      end
      i += 1

      if arr.size % 1000 == 0
        es_bulk_insert(arr)
        arr.clear
        `echo #{i} > es-import-rdns-lino.txt`
        print "#{i}                \r"
      end
      #ap @client.indices.analyze index: @index, type: @type, text: line, analyzer: 'dot_split_analyzer'
    }

    if arr.size>0
      es_bulk_insert(arr)
      arr.clear
    end
  end
end

if ARGV[0]
  RdnsBulkIndex.new(ARGV[0], ARGV[1] || 0).run
else
  puts "#{$0} <rdns_file_path>"
end
