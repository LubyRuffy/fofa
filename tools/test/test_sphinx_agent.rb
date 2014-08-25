#!/usr/bin/env ruby
require 'yaml'
require 'benchmark'

@root_path = File.expand_path(File.dirname(__FILE__))
Dir.chdir @root_path

ips = YAML::load(File.open(@root_path+"/../../config/ips.yml"))['sphinx_servers']

class String
  def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end

rs = []
ips.split(',').each_with_index{|h,i|
  result = Benchmark.measure do
    @info = `./test.py -h #{h} -p 9312 -i idx1p#{i} test -l 1`.string_between_markers('times in ',' documents')
  end
  rs << "------> #{h} => #{@info} : cost time :"+result.to_s
}

rs.each{|r| puts r}