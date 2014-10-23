#!/usr/bin/env ruby
require 'thread/pool'
require 'net/http'

pool = Thread.pool(100)

while (s = $stdin.gets)
  pool.process(s.strip) {|h|
    res = Net::HTTP.get(h, '/shownews.asp?id=1')
    puts h if res.include?('svcomment')
  }
end

pool.shutdown