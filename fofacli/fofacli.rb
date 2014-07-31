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
    @args[:mode] = args.pop || 's' # Last argument should be the mode
    @args[:params] = {}
    args.each{|p|
      ps = p.split('=')
      k = ps.shift
      v = ps.join('=')
      @args[:params][k] = v
    } # Whatever is in the middle should be the params
  end

  def usage(str = nil, extra = nil)
    $stdout.puts "Usage: #{$0} <exploit_name> [option=value] [mode]"
    $stdout.puts "Error: #{str}\n\n" if str
    $stdout.puts extra + "\n" if extra
    $stdout.puts
  end

  def dump_module_list
    $stdout.puts "[*] Please wait while we load the module tree..."
    $stdout.puts ""
    #todo: load exploits in exploits/*.rb
    ext = ''
    Dir["exploits/*.rb"].each do |filename|
      ext << "\t"+File.basename(filename, '.rb')
      ext << "\n"
    end
    ext
  end

  def dump_modes
    ext = %Q{===== Show mode =====
h\t:\tshow mode list [DEFAULT]
i\t:\tshow module infomation
s\t:\tscan vulnerability
e\t:\texploit vulnerability(in development)}
  end

  def engage_mode(modules)
    case @args[:mode].downcase
      when 'h'
        ext = dump_modes
        usage(nil, ext)
      when 'i'
        show_module_info(modules)
      when 's'
        execute_module(modules)
      when 'e'
        execute_module(modules, 'exploit')
      else
        ext = dump_modes
        usage("Invalid mode #{@args[:mode]}", ext)
    end
  end


  def show_module_info(modules)
    modules.info.each{|k,v|
      $stdout.printf("%-20s\t:\t%s\n", k, v.to_s ) if k!="ScanSteps"
    }
  end

  def init_modules
    $stdout.puts "[*] Initializing modules..."
    module_name = @args[:module_name]
    exploits_path = File.expand_path(File.join(File.dirname(__FILE__), 'exploits', module_name+".rb"))
    if !File.exist? exploits_path
      $stdout.puts "[*] ERROR: not found module name as #{module_name}: #{exploits_path}"
      ext = dump_module_list
      usage(nil, ext)
      exit
    end
    require exploits_path
    return FofaExploits.new
  end

  def execute_module(m, mod='scan')
    #p @args[:params]
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
      if res['error']
        $stderr.puts "[ERROR] receive fofa results failed: #{res['error']}"
      else
        JSON.parse(res.body)['results'].each{|h|
          if mod=='scan'
            puts "#{h} : #{m.vulnerable(h)?"vulnerable":"-"}"
          else
            puts "#{h} : #{m.exploit(h)}"
          end
        }
      end

    else
      puts "no target to scan, set hostinfo=127.0.0.1:80 or fofaquery='body=\"123\"'"
      exit
    end
  end

  def run!

    if @args[:module_name].nil? || @args[:module_name] == "-h"
      ext = dump_module_list
      usage(nil, ext)
      exit
    end

    mod = init_modules

    engage_mode(mod)
    $stdout.puts
  end
end

if __FILE__ == $PROGRAM_NAME
  cli = Fofacli.new(ARGV)
  cli.run!
end