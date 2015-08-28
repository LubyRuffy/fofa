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

class RdnsBulkIndex
  def initialize(file='rdns.txt', startline=0)
    @file = file
    @progress_file = 'es-import-rdns-lino.txt'
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
      begin
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
      rescue => e
        puts r, e
      end

    }
    records
  end

  def es_bulk_insert(res, refresh=false)
    records = prepare_records(res)
    while true
      begin
        @client.bulk body: records, refresh: refresh
        break
      rescue => e
        puts "[ERROR] : #{e}"
      end
    end

  end

  def run
    create_mapping

    arr = []
    i = 0
    File.open(@file).each_line { |line|
      if i >= @startline
        arr << line
      else
        print "  #{i}                \r" if i % 500000 == 0
      end
      i += 1

      if arr.size % 10000 == 0 && arr.size>0
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
  RdnsBulkIndex.new(ARGV[0], ARGV[1] || 0).run
else
  puts "#{$0} <rdns_file_path> [start_line]"
end
