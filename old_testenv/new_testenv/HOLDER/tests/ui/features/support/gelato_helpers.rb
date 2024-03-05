require 'selenium/client'
require 'yaml'
require 'base64'
require 'rubygems'

Before do
  create_new_selenium_driver
  start_new_browser_session
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
  application_host = "127.0.0.1"
  application_port = ENV['VELOCITY_WEBSERVER_PORT'] || "3000"
  @application_url = "http://#{application_host}:#{application_port}"
  @start_url = "http://www.google.com"
  @selenium_driver = Selenium::Client::Driver.new(
    remote_control_server,
    port,
    browser,
    @start_url,
    timeout)

  encoded = Base64.encode64("#{'emcgowan'}:#{'shaeC3ra!'}").strip
  page.remote_control_command('addCustomRequestHeader',
                              ['Authorization', "Basic #{encoded}"])
end

def start_new_browser_session
  @selenium_driver.start_new_browser_session
  @selenium_driver.set_context "Starting example '#{self.description}'" unless not(self.respond_to?('description'))
end

