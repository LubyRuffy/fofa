#!/usr/bin/env ruby
#生成md5密码文件，给fofacli用
#第一列是明文 空格分隔 后面没一列都对应一个密文hash

require 'digest'

if File.exists?(ARGV[0])
  File.open(ARGV[0]).each_line do |line|
    line.strip!
    puts "#{line} #{Digest::MD5.hexdigest(line)}"
  end
end