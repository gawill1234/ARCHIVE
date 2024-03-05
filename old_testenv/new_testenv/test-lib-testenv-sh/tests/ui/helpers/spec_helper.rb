require "selenium/client"
require "yaml"
require File.expand_path(File.dirname(__FILE__) + "/test_helper")

def start_new_browser_session
  @selenium_driver.start_new_browser_session
  @selenium_driver.set_context "Starting example '#{self.description}'" unless not(self.respond_to?('description'))
end

def selenium_driver
  @selenium_driver
end

def page
  @selenium_driver
end

def create_new_selenium_driver
  remote_control_server = ENV['SELENIUM_RC_HOST'] || "localhost"
  port = ENV['SELENIUM_RC_PORT'] || 4444
  browser = ENV['SELENIUM_RC_BROWSER'] || "*firefox"
  timeout = ENV['SELENIUM_RC_TIMEOUT'] || 200
  application_host = ENV['SELENIUM_APPLICATION_HOST'] || "ux-qa-7.5.apps2.vivisimo.com"
  application_port = ENV['VELOCITY_WEBSERVER_PORT'] || "9080"
  @application_url = "http://#{application_host}:#{application_port}"
  application_install_dir = ENV['VIV_INSTALL_DIR'] || "/usr/local/vivisimo-ux-qa-7.5/"
  @application_example_path = "file://:#{application_port}#{application_install_dir}examples/data/metadata-example/"

  @selenium_driver = Selenium::Client::Driver.new(
    remote_control_server,
    port,
    browser,
    @application_url,
    timeout)
end

environment_token = ENV['ENV_TOKEN']
if environment_token
  Dir.glob("config/*.yaml").each do |file|
    config_obj = YAML::load_file(file)
    if config_obj[environment_token]
      config_obj[environment_token].each_pair{|key, val|
        ENV[key]=val.to_s
      }
    end
  end
end

def setup_variables
  @application_user     = ENV['VIV_USER'] || 'test-all'
  @application_password = ENV['VIV_PASSWORD'] || 'P@$$word#1?'
  @iopro_user           = ENV['IOPRO_USER'] || 'cox'
  @iopro_password       = ENV['IOPRO_PASSWORD'] || 'baseball'
end

def cgi_paths
  virtual_dir = ENV['VIV_VIRTUAL_DIR'] || 'vivisimo'
  exe = ENV['VIV_TARGET_OS'] == 'windows' ? '.exe' : ''
  application_port = ENV['SELENIUM_APPLICATION_PORT'] || "80"
  base = "http://#{ENV['SELENIUM_APPLICATION_HOST']}:#{application_port}"
  @admin      = "#{base}/#{virtual_dir}/cgi-bin/admin#{exe}".freeze
  @admin_axl  = "#{base}/#{virtual_dir}/cgi-bin/admin-axl#{exe}".freeze
  @query_meta = "#{base}/#{virtual_dir}/cgi-bin/query-meta#{exe}".freeze
  @velocity   = "#{base}/#{virtual_dir}/cgi-bin/velocity#{exe}".freeze
end

RSpec.configure do |config|
  config.before(:all) do
    create_new_selenium_driver
    cgi_paths
    setup_variables
  end

  config.after(:all) do
    @selenium_driver.close_current_browser_session
  end
end