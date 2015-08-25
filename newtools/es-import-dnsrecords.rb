#!/usr/bin/env ruby

$root_path = File.expand_path(File.dirname(__FILE__))
require 'yaml'
require 'awesome_print'
require 'elasticsearch/model'

class Sidekiq
  def self.server?
    false
  end
end
require $root_path+"/../config/initializers/elasticsearch.rb"

class DnsrecordBulkIndex
  def initialize(file='dnsrecords.txt', startline=0)
    @file = file
    @progress_file = 'es-import-dnsrecords-lino.txt'
    @startline = startline

    if @startline == 0  && File.exists?($root_path + @progress_file)
      File.open($root_path + @progress_file){|f|
        line = f.readline()
        @startline = line.strip!.to_i
        puts "[INFO] read line from #{$root_path + @progress_file} : #{@startline}"
      }
    end


    if !File.exist?(@file)
      puts "[ERROR] File not exists, quit..."
      exit
    end
    @client = Elasticsearch::Model.client
    @index = 'dnsrecords'
    @type = 'dnsrecords'
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
                  dnsrecords: {
                      properties: {
                          host: {
                              type: 'multi_field',
                              fields: {
                                  hoststr: {
                                      type: "string",
                                      analyzer: "dot_split_analyzer"
                                  },
                                  hostraw: {
                                      type: "string",
                                      index: "not_analyzed"
                                  }
                              }
                          },
                          dnstype: {
                              type: 'string',
                              index: "not_analyzed"
                          },
                          to: {
                              type: 'multi_field',
                              fields: {
                                  tostr: {
                                      type: "string",
                                      analyzer: "dot_split_analyzer"
                                  },
                                  toraw: {
                                      type: "string",
                                      index: "not_analyzed"
                                  }
                              }
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
      begin
      r.strip!
      host,type,to = r.split(',')
      records << {
          index: {
              _index: @index,
              _type: @type,
              _id: host,
              data: {
                  host: host,
                  dnstype: type,
                  to: to
              }
          }
      }
      rescue => e
        puts r, e
      end

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
      else
        print "  #{i}                \r" if i % 10000 == 0
      end
      i += 1

      if arr.size % 5000 == 0 && arr.size>0
        es_bulk_insert(arr)
        arr.clear
        `echo #{i} > #{$root_path + @progress_file}`
        print "  #{i}                \r"
      end
      #ap @client.indices.analyze index: @index, type: @type, text: line, analyzer: 'dot_split_analyzer'
    }

    if arr.size>0
      es_bulk_insert(arr)
      arr.clear
      i += arr.size
      `echo #{i} > #{$root_path + @progress_file}`
      print "  #{i}                \r"
    end
  end
end

if ARGV[0]
  DnsrecordBulkIndex.new(ARGV[0], ARGV[1] || 0).run
else
  puts "#{$0} <dnsrecords_file_path> [start_line]"
end
