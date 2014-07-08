#!/usr/bin/env ruby
#提供几个url，分析共同点
#ARGV[0] url1 url2...

root_path = File.expand_path(File.dirname(__FILE__))
require root_path+"/../app/jobs/module/webdb2_class.rb"
require 'diff/lcs'
require 'diff/lcs/htmldiff'
require 'uri'



class Diff::LCS::HTMLDiff
  class MyCallbacks
    attr_accessor :output
    attr_accessor :match_class
    attr_accessor :only_a_class
    attr_accessor :only_b_class

    def initialize(output, options = {})
      @output = output
      options ||= {}

      @match_class = options[:match_class] || "match"
      @only_a_class = options[:only_a_class] || "only_a"
      @only_b_class = options[:only_b_class] || "only_b"
    end

    # This will be called with both lines are the same
    def match(event)
      #@output << htmlize(event.old_element, :match_class)
      @output << event.old_element
    end

    # This will be called when there is a line in A that isn't in B
    def discard_a(event)
      #@output << htmlize(event.old_element, :only_a_class)
    end

    # This will be called when there is a line in B that isn't in A
    def discard_b(event)
      #@output << htmlize(event.new_element, :only_b_class)
    end
  end

  def run
    callbacks = MyCallbacks.new(@options[:output])
    Diff::LCS.traverse_sequences(@left, @right, callbacks)
    @options[:output]
  end
end

def hostinfo_of_url(url)
  begin
    url = 'http://'+url+'/' if !url.include?('http://') and !url.include?('https://')
    url = URI.encode(url) unless url.include? '%' #如果包含百分号%，说明已经编码过了
    uri = URI(url)
    rr = uri.host
    rr = rr+':'+uri.port.to_s if uri.port!=80 && uri.port!=443
    rr
  rescue => e
    puts e
    nil
  end
end


@m = WebDb.new(root_path+"/../config/database.yml")
@sql = "select header,title,body from subdomain where 1=2"
ARGV.each{|a|
  host = hostinfo_of_url(a)
  @sql += " or host='#{Mysql2::Client.escape(host)}'" if host
}

r = @m.mysql.query(@sql)
if r.size>0
  array_body = []
  r.each{|x|
    array_body << x['body']
  }
  if array_body.size>1
    arr =  array_body.inject { |result, e|
      same_string = StringIO.new
      Diff::LCS::HTMLDiff.new(result.lines, e.lines,
                              :expand_tabs => 0,
                              :output => same_string).run
      same_string.string
    }.lines.reject{|x|
      #x.size<20 ||
      x.include?('html') || x.include?('script') || x.include?('head') || x.include?('<')
    }.sort{|x,y| y.size<=>x.size }
    if arr.size>0
      puts "body=\"#{Mysql2::Client.escape(arr[0].strip)})\""
    else
      puts "no result"
    end
  end
end