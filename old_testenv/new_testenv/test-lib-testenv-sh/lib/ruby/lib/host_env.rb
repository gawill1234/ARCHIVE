#! /usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'testenv'

class HostEnv
  attr_reader :filename, :vars, :env_from_file
  attr_reader :base, :user, :password, :gronk, :velocity

  def initialize(filename=nil)
    @filename = filename
    @vars = ['VIVHOST',
             'VIVHTTPPORT',
             'VIVPORT',
             'VIVPW',
             'VIVTARGETOS',
             'VIVUSER',
             'VIVVIRTUALDIR']
    @env_from_file = {}
  end

  def read_file
    # Fill in all of the defaults...
    @vars.each {|v| @env_from_file[v] = ENV[v]}

    if @filename.nil?
      puts "Filename was not given, using default environment."
      return true
    end

    begin
      file = File.new(filename, "r")
      for line in file.readlines
        #print line, "\n"
        export_line = line.match(/^export \w*=.*/).to_s
        if (! export_line.empty?)
          env_name = export_line.match(/\S*=/).to_s
          env_name = env_name[0..env_name.length-2]
          env_val = export_line.match(/=\S*/).to_s
          env_val = env_val[1..env_val.length]
          if (@vars.include?(env_name))
            @env_from_file[env_name] = env_val
          end
        end
      end
      file.close
    rescue => err
      print "Exception: #{err}\n"
      return false
    end
    return true
  end

  def parse_env
    if (! read_file)
      return false
    end

    windows = (@env_from_file['VIVTARGETOS'] == 'windows')
    exe = windows ? '.exe' : ''
    base_string = "http://#{env_from_file['VIVHOST']||'localhost'}:" \
                  "#{env_from_file['VIVHTTPPORT']||'80'}/" \
                  "#{env_from_file['VIVVIRTUALDIR']||'vivisimo'}/"
    @base = URI.parse(base_string).normalize.freeze
    @velocity =  @base.merge("cgi-bin/velocity#{exe}").normalize.freeze
    @gronk = @base.merge("cgi-bin/gronk#{exe}").normalize.freeze
    @user = (env_from_file['VIVUSER'] || 'test-all').freeze
    @password = (env_from_file['VIVPW'] || 'P@$$word#1?').freeze
    return true
  end

  def get_host_addr
    env_from_file['VIVHOST']
  end
end

if __FILE__ == $0
  hostenv = HostEnv.new(ARGV[0])
  hostenv.parse_env
  print "Host initialized with: #{hostenv.base}, #{hostenv.velocity}, #{hostenv.gronk}, #{hostenv.user}, #{hostenv.password}\n"
end
