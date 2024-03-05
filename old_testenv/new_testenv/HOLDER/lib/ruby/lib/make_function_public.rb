#!/bin/env ruby

require 'misc'

def make_function_public(vapi, name)
  name.gsub!('_','-')

  resp = vapi.repository_get_md5(:element => 'function', :name => name)
  old_function = resp.xpath('/result/repository-node/function').first
  return if old_function['type'] == 'public-api'

  md5 = resp.xpath('/result/md5/text()')

  old_function['type'] = 'public-api'

  new_md5 = vapi.repository_update(:node => old_function, :md5 => md5)
end

def restore_internal_function(vapi, name)
  name.gsub!('_','-')

  resp = vapi.repository_delete(:element => 'function', :name => name)
end

def publicize_function(vapi, name)
  begin
    make_function_public(vapi, name)
    yield
  ensure
    restore_internal_function(vapi, name)
  end
end

if __FILE__ == $0
  vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  if (ARGV[0].nil? || (ARGV[0] == '-r' && ARGV[1].nil?))
    puts "Usage: #{__FILE__} [-r] function-name"
    puts "  -r : Restore node to internal version"
    puts "  function-name : Name of the function to make public"
  elsif ARGV[0] == '-r'
    restore_internal_function(vapi, ARGV[1])
  else
    make_function_public(vapi, ARGV[0])
  end
end
