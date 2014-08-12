#!/usr/bin/env ruby

@root_path = File.expand_path(File.dirname(__FILE__))
Dir.chdir @root_path

class String
  def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end

rs = []
%w|10.108.72.81 10.108.72.37 10.108.72.105 10.108.72.108 10.108.72.109|.each_with_index{|h,i|
  info = `./test.py -h #{h} -p 9312 -i idx1p#{i} test -l 1`.string_between_markers('times in ',' documents')
  rs << "------> #{h} => #{info}"
}

rs.each{|r| puts r}