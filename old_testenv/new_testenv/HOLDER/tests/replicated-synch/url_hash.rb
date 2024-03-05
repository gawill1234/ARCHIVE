class UrlHash
  attr_reader :name, :replicated_count, :finished_count, :hash, :results

  def initialize(name, results, url_locator = UrlHash::DirectUrlLocator.new)
    @name = name
    @hash = {}
    @replicated_count = 0
    @finished_count = 0
    @results = results
    @url_locator = url_locator
  end

  def input_log_entry(entry)
    value = ''
    replicated = false
    if (entry['replicated'] =~ /^replicated/)
      replicated = true
      @replicated_count = @replicated_count + 1
    else
      @finished_count = @finished_count + 1
    end

    url = @url_locator.url_for_entry(entry)
    if not @hash.key?(url)
      value = replicated ? 'replicated' : 'finished'
    else
      value = @hash[url]

      if value == 'replicated'
        if replicated
          results.add_failure("#{url} was replicated twice on #{name}!")
        else
          value = 'finished-and-replicated'
        end
      elsif value == 'finished'
        if not replicated
          results.add_failure("#{url} was finished twice on #{name}!")
        else
          value = 'finished-and-replicated'
        end
      else
        results.add_failure("#{name}: #{url} has already been finished and replicated and was found in the audit log again with replicated = #{replicated}")
      end
    end

    @hash[url] = value
  end

  def input_log_entries(entries)
    if not entries
      return
    end

    success_entries = entries.select {|e| e['status'] =~ /^success/}
    success_entries.each {|e| input_log_entry(e) }
    # TODO: use results to check for no unsuccessful entries
  end

  def clear
    @hash = {}
    @replicated_count = 0
    @finished_count = 0
  end
end

# This will find the URL for crawl-urls and crawl-deletes (top-level
# items in the audit log)
class UrlHash::DirectUrlLocator
  def url_for_entry(entry)
    entry.child['url']
  end
end
