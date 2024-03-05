#!/usr/bin/env ruby

require "misc"
require "vapi"
require 'make_function_public'
require 'gronk'

results = TestResults.new('Tests the search-url-from-vfile function.')
results.need_system_report = false

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

VFILE_NAME = 'test_v_file'

def copy_test_vfile_to_installation(name, target_name)
  gronk = Gronk.new

  install_dir = gronk.installed_dir
  target_path = File.join(install_dir, 'tmp', target_name)

  # Gronk doesn't properly overwrite old files
  gronk.rm_file(target_path)
  gronk.send_file(name, target_path)
end

def it_returns_a_url_to_the_collection(vapi, results)
  url = vapi.search_url_from_vfile(:file => VFILE_NAME, :key => 'test://127.0.0.1:80/file/image.jpg/', :user_name => 'test-user')
  url = url.root.text

  results.add_matches('http://127.0.0.1:7205/search', url)
  results.add_matches('collection=my-awesome-collection', url)
end

def it_disallows_access_to_someone_elses_file(vapi, results)
  results.expect_exception(VapiException) do
    vapi.search_url_from_vfile(:file => VFILE_NAME, :key => 'test://127.0.0.1:80/file/image.jpg/', :user_name => 'evil')
  end
end



copy_test_vfile_to_installation('vfile', VFILE_NAME)

publicize_function(vapi, 'search-url-from-vfile') do
  it_returns_a_url_to_the_collection(vapi, results)
  it_disallows_access_to_someone_elses_file(vapi, results)
end

results.cleanup_and_exit!(true)
