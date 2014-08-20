#!/usr/bin/env ruby
require 'sshkit'
require 'sshkit/dsl'
require 'optparse'
require 'ostruct'

Version = '0.1'

class OptparseExample

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.verbose = false
    options.username = ENV['USERNAME'] || `whoami`.split(/[\r\n]/)[0]
    options.password = nil
    options.mode = :sequence
    options.display_results = true
    options.servers = []

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [options] cmdline"

      opts.separator ""
      opts.separator "Specific options:"

      # Mandatory argument.
      opts.on("-u", "--username USERNAME",
              "Username to ssh loginm, default is current user") do |username|
        options.username = username
      end

      opts.on("-p", "--password PASSWORD",
              "Password to ssh login") do |password|
        options.password = password
      end

      opts.on("-h", "--hosts HOSTS_FILE_PATH",
              "Each line is a host, could be '1.1.1.1' or 'user@a.com'") do |hostfile|
        options.servers = File.readlines(hostfile).map{|l| l.strip}.select{|l| !l.include?'#'}
      end

      opts.on("-m", "--mode MODE",
              "Could be : sequence, parallel, groups, default is sequence") do |mode|
        options.mode = mode.to_sym
      end

      opts.on("-n", "--no-display",
                 "Do not display results of command execution") do
        options.display_results = false
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("--help", "Show this message") do
        puts opts
        exit
      end

      # Another typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts ::Version.join('.')
        exit
      end

    end

    opt_parser.parse!(args)
    options
  end  # parse()

end  # class OptparseExample

options = OptparseExample.parse(ARGV)

unless options.servers.size>0
  puts "ERROR: no server to execute!"
  puts options
  exit
end

unless ARGV.size>0
  puts "ERROR: no command to execute!"
  puts options
  exit
end

#SSHKit.config.default_env = { path: '/usr/local/bin:$PATH' }
#SSHKit.config.format = :dot
servers = options.servers.collect do |s|
  user_host = s
  user_host = "#{options.username}@#{user_host}" if options.username && !s.include?('@')
  h = SSHKit::Host.new(user_host)
  h.password = options.password if  options.password
  h
end

puts "execute #{ARGV} as #{options.username} at #{options.servers.size} servers, mode is : #{options.mode}"
commands = ARGV
commands = ARGV[0].split(' ') if ARGV.size==1
on servers, in: options.mode do |s|
  #begin

    if options.display_results
      puts "=====#{s}=====",capture( commands[0], commands[1..-1] )
    else
      execute(commands[0], commands[1..-1])
    end
  #rescue SSHKit::Runner::ExecuteError => e
  #  puts e
  #rescue => e
  #  puts e
  #end
end