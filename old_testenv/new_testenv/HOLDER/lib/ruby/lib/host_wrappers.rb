#! /usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'host_env'
require 'vapi'
require 'gronk'

def host_collection(name, filename=nil)
  hostenv = HostEnv.new(filename)
  if not hostenv.parse_env
    return nil
  end
  [Collection.new(name, hostenv.velocity, hostenv.user, hostenv.password), hostenv.get_host_addr]
end

def host_vapi(filename)
  hostenv = HostEnv.new(filename)
  if not hostenv.parse_env
    return nil
  end
  [Vapi.new(hostenv.velocity, hostenv.user, hostenv.password), hostenv.get_host_addr]
end

def host_gronk(filename)
  hostenv = HostEnv.new(filename)
  if not hostenv.parse_env
    return nil
  end
  [Gronk.new(hostenv.gronk), hostenv.get_host_addr]
end

if __FILE__ == $0
  c, addr = host_collection(ARGV[0], ARGV[1])
  print "Addr is: #{addr}\n"
  c.delete
  c.create
end
