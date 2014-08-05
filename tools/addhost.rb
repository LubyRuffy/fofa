#!/usr/bin/env ruby
#提交host工具，默认超过90天才更新，不过可以设置第二个参数来强制刷新
if __FILE__==$0
  if ARGV.size<1
    puts "Usage : #{ARGV[0]} <URL> [force_update, default=0]"
  end
  require 'benchmark'

  result = Benchmark.measure do
    @root_path = File.expand_path(File.dirname(__FILE__))
    puts @root_path
    require @root_path+"/../app/workers/module/process_class.rb"
  end
  puts "===Require time : "+result.to_s

  #include HttpModule

  #puts get_http('www.fofa.so')
  result = Benchmark.measure do
    @p = Processor.new
  end
  puts "===Mysql connection time : "+result.to_s

  force_udpate=false
  force_udpate=true if ARGV[1].to_i==1
  if File.exists?(ARGV[0])
    File.open(ARGV[0]).each_line do |line|
      if line[0]!='#'
        puts line
        @p.add_host_to_webdb line.strip, force_udpate
      end
    end
  else
    result = Benchmark.measure do
      @p.add_host_to_webdb ARGV[0], force_udpate
    end
    puts "===Process time : "+result.to_s
  end

end
