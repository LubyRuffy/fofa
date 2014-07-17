#/usr/bin/env ruby
clibase = __FILE__
while File.symlink?(clibase)
  clibase = File.expand_path(File.readlink(clibase), File.dirname(clibase))
end

$:.unshift(File.expand_path(File.join(File.dirname(clibase), '..', 'lib'))).unshift(File.expand_path(File.join(File.dirname(clibase), '..')))
require 'payload/webshell'

gem "minitest"
require 'minitest/unit'
require 'minitest/autorun'

class TestPayloud < MiniTest::Unit::TestCase

  def setup
  end

  def test_war_deploy
    war = WebshellPayload.generate_war_webshell('123')
    p war
    assert war
  end
end
