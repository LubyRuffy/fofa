#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-

clibase = __FILE__
while File.symlink?(clibase)
  clibase = File.expand_path(File.readlink(clibase), File.dirname(clibase))
end

$:.unshift(File.expand_path(File.join(File.dirname(clibase), 'lib')))
.unshift(File.expand_path(File.join(File.dirname(clibase))))
.unshift(File.expand_path(File.join(File.dirname(clibase), 'gem_lib')))

class Fofacli
  def initialize(args)
    @args = {}

    @args[:module_name] = args.shift # First argument should be the module name
    @args[:mode] = args.pop || 'h' # Last argument should be the mode
    @args[:params] = {}
    args.each{|p|
      ps = p.split('=')
      k = ps.shift
      v = ps.join('=')
      @args[:params][k] = v
    } # Whatever is in the middle should be the params
  end

  def usage(str = nil, extra = nil)
    $stdout.puts "Usage: #{$0} <exploit_name> <option=value> [mode]"
    $stdout.puts "Error: #{str}\n\n" if str
    $stdout.puts extra + "\n" if extra
    $stdout.puts
  end

  def dump_module_list
    $stdout.puts "[*] Please wait while we load the module tree..."
    #todo: load exploits in exploits/*.rb
    ext = ''
    Dir["exploits/*.rb"].each do |filename|
      ext << filename
      ext << "\n"
    end
    ext
  end

  def engage_mode(modules)
    case @args[:mode].downcase
      when 'h'
        usage
=begin
      when "s"
        show_summary(modules)
      when "o"
        show_options(modules)
      when "a"
        show_advanced(modules)
      when "i"
        show_ids_evasion(modules)
      when "p"
        if modules[:module].file_path =~ /auxiliary\//i
          $stdout.puts("\nError: This type of module does not support payloads")
        else
          show_payloads(modules)
        end
      when "t"
        puts
        if modules[:module].file_path =~ /auxiliary\//i
          $stdout.puts("\nError: This type of module does not support targets")
        else
          show_targets(modules)
        end
      when "ac"
        if modules[:module].file_path =~ /auxiliary\//i
          show_actions(modules)
        else
          $stdout.puts("\nError: This type of module does not support actions")
        end
      when "c"
        show_check(modules)
=end
      when "e"
        execute_module(modules)
      else
        usage("Invalid mode #{@args[:mode]}")
    end
  end

  def init_modules
    $stdout.puts "[*] Initializing modules..."
    module_name = @args[:module_name]
    exploits_path = File.expand_path(File.join(File.dirname(__FILE__), 'exploits', module_name))
    require exploits_path
    FofaExploits.new
  end

  def execute_module(m)
    p @args[:params]
    if @args[:params]["hostinfo"]
      m.vulnerable(@args[:params]["hostinfo"])
    elsif @args[:params]["fofaquery"] || m.info['FofaQuery']
      require 'net/http'
      require 'json'
      require 'base64'
      require 'cgi'

      fofaquery = @args[:params]["fofaquery"] || m.info['FofaQuery']
      uri = URI('http://fofa.so/api/result?qbase64='+CGI.escape(Base64.encode64(fofaquery)))
      res = Net::HTTP.get_response(uri)
      JSON.parse(res.body)['results'].each{|h|
        puts "#{h} : #{m.vulnerable(h)?"vulnerable":"-"}"
      }
    else
      puts "no target to scan, set hostinfo=127.0.0.1:80 or fofaquery='body=\"123\"'"
      exit
    end
  end

  def run!
    if @args[:module_name] == "-h"
      usage()
      exit
    end

    if @args[:module_name].nil?
      ext = dump_module_list
      usage(nil, ext)
      exit
    end

    mod = init_modules

    # Process special var/val pairs...
    #process_cli_arguments(@args[:params])

    engage_mode(mod)
    $stdout.puts
  end
end

if __FILE__ == $PROGRAM_NAME
  cli = Fofacli.new(ARGV)
  cli.run!
end