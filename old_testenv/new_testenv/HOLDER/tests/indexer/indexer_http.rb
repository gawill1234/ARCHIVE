class IndexerHTTP
  def initialize(collection)
    @collection = collection
    @http = Net::HTTP.new(ENV['VIVHOST'], ENV['VIVPORT'])
  end

  def search(user_options = {})
    options = {}

    # Change underscored symbols to Vivisimo dashes
    user_options.each do |k,v|
      k = k.to_s.gsub('_', '-')
      options[k] = v
    end

    options[:collection] = @collection

    query = hash_to_query(options)
    response = @http.request_get("/search?#{query}")
    Nokogiri::XML(response.body).root.freeze
  end

  private

  def hash_to_query(hash)
    hash.map {|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"}.join('&')
  end
end
