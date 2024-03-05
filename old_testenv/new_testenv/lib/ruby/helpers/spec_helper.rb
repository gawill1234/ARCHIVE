$LOAD_PATH << ENV['RUBYLIB']
require 'loader'

RSpec.configure do |config|
  config.before(:all) do
		connect_to_velocity
  end
end
