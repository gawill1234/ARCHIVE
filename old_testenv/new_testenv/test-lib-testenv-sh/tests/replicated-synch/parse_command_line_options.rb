require 'optparse'

def parse_command_line_options
  options = {}

  optparse = OptionParser.new do |opts|

    opts.on('-S', '--server FILE', "Server environment configuration file") do |f|
      if not options.key?(:server1cfg)
        options[:server1cfg] = f
      else
        options[:server2cfg] = f
      end
    end

    opts.on('-C', '--client FILE', "Client environment configuration file") do |f|
      if not options.key?(:client1cfg)
        options[:client1cfg] = f
      else
        options[:client2cfg] = f
      end
    end
  end

  optparse.parse!

  options
end
