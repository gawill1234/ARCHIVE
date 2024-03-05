#
# Install a Velocity Plugin on a remote velocity installation.  
# 
# Run with --help to see usage information
#   

require 'vapi'
require 'gronk'
require 'uri'
require 'libarchive'
require 'tempfile'

XMLfilePattern=/^data.*\.xml$/

class ConnectorInstaller

  def initialize( velocityURL, username, password )
    @velocityURL = velocityURL
    @vapi = Vapi.new( @velocityURL, username, password)
  end

  def upload_and_unpack_to_velocity_root( connector_path ) 
    #Doesn't work:  Gronk server and clients need to support multipart attachments and base64 encoding
    exe =@velocityURL.match(/\.exe/)
    gronk_url = URI.parse( @velocityURL )
    gronk_url = gronk_url.merge("gronk#{exe}").normalize.freeze

    gronk = Gronk.new( gronk_url )
    install_dir = gronk.installed_dir

    remote_path = "#{install_dir}/InstallConnector.zip".gsub("\\", "/")
    gronk.send_file( connector_path, remote_path)

    command = fix_path( install_dir + '/bin/unzip') +
                       ' -o #{install_dir}/InstallConnector.zip -d .'
    gronk.execute(command)
    gronk.rm_file "#{install_dir}/InstallConnector.zip" 
  end

  def extract_seeds( filename )
    seeds = []
    Archive.read_open_filename(filename) do |archive|
      while entry = archive.next_header
        if(not entry.directory? and XMLfilePattern.match entry.pathname)
          yield entry.pathname, Nokogiri::XML( archive.read_data)
        end
      end
    end
  end

  def install_package( connector_path )
    extract_seeds(connector_path) { |filename, seed|
      repository_nodes = @vapi.repository_list_xml
      p = repository_nodes.search("function[@name='#{seed.root.attributes["name"]}']")
      if not p.empty?
        puts "%s element with name %s from %s exists ...updating." % 
              [ seed.root.name, seed.root.attributes["name"], filename ]
        puts @vapi.repository_update( :node => seed.root )        
      else
        puts "%s element with name %s from %s does not exist. adding..." % 
              [ seed.root.name, seed.root.attributes["name"], filename ]
        puts @vapi.repository_add( :node => seed.root )
      end
    }
  end
end



if __FILE__ == $0

  require 'trollop'
  opts = Trollop::options do
    opt(:connector, 'Connector path', :type => :string, :required => true )
    opt(:target, 'Target velocity instance URL', :default => "#{TESTENV.velocity}" )
    opt(:upload, 'Upload the connector file to velocity (Not working!)', :default => false)
  end


  #get these form the environment
  username = TESTENV.user
  password = TESTENV.password
  installer = ConnectorInstaller.new( opts[:target], username, password )  
  if opts[:upload]
    installer.upload_and_unpack_to_velocity( opts[:connector] )
  end
  installer.install_package opts[:connector] 
end

