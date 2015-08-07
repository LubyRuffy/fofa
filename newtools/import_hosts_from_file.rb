#!/usr/bin/env ruby

if ARGV.size<1
  puts "Usage : <FILE> [lineno default 0]"
  exit
end

@root_path = File.expand_path(File.dirname(__FILE__))
#puts @root_path
require 'active_record'
require 'elasticsearch/model'
require @root_path+"/../config/initializers/sidekiq.rb"
require @root_path+"/../config/initializers/elasticsearch.rb"
require @root_path+"/../app/workers/checkurl.rb"

$startline = ARGV[1] || 0
$startline = $startline.to_i
$lineno = 0
File.open(ARGV[0]).each_line{|line|
  host = line.strip
  if $lineno >= $startline
    CheckUrlWorker.perform_async(host)
  end
  $lineno = $lineno + 1
  if $lineno % 1000 ==0
    `echo #{$lineno} > import_process.txt`
    print "#{$lineno}                \r"
  end
}


