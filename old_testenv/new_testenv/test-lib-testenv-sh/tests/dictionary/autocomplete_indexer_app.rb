require 'digest/md5'

class AutocompleteIndexerApp
  attr_accessor :authentication_type, :username, :password

  def initialize(collection)
    @collection = collection
    @http = Net::HTTP.new(ENV['VIVHOST'], ENV['VIVPORT'])
    @authentication_type = :username
    @username = TESTENV.user
    @password = TESTENV.password
  end

  def get_data(fields, options = {})
    options[:collection] = @collection
    options['v.app'] = 'dictionary-retrieve-collection-data'
    options[:contents] = fields.join("\n")
    options[:count] = options[:count] || 10

    if options[:metadata]
      options[:metadata] = options[:metadata].join("\n")
    end

    case @authentication_type
    when :username
      options['v.username'] = @username
      options['v.password'] = @password
      query = hash_to_query(options)
    when :su_token
      query = create_su_token_query(options)
    else
      query = hash_to_query(options)
    end

    response = @http.request_get("/axl?#{query}")
    Nokogiri::XML(response.body).root.freeze
  end

  def each_page(fields, options = {})
    next_page = nil

    while true
      options[:last] = next_page if next_page

      index_data = get_data(fields, options)

      exceptions = index_data.xpath('//exception')
      if exceptions.size > 0
        raise "indexer application had exception: #{exceptions}"
      end

      documents = index_data.xpath('/vce/results/document')
      yield documents unless documents.empty?

      next_page = index_data.xpath('/vce/results/r')
      break if next_page.empty?
    end
  end

  def each_document(fields, options = {})
    doc_count = 0

    each_page(fields, options) do |documents|
      documents.each do |doc|
        yield doc, doc_count
        doc_count += 1
      end
    end
  end

  private

  def hash_to_query(hash)
    hash.map {|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join('&')
  end

  def create_su_token_query(options)
    token_file_name = 'dictionary-su-token'

    options['v.su-token'] = token_file_name
    query = hash_to_query(options)
    md5 = Digest::MD5.hexdigest(query)

    File.open('temp-md5', 'w') do |f|
      f.write(md5)
    end

    gronk = Gronk.new

    install_path = gronk.installed_dir
    dest_path = "#{install_path}/data/su-tokens/#{token_file_name}"
    gronk.send_file('temp-md5', dest_path)

    File.delete('temp-md5')

    return query
  end
end
