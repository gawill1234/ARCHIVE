class Autocomplete
  def initialize(dictionary)
    @dictionary = dictionary
    @vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
  end

  def suggestions(str, options=nil)
    options = options || {}
    options[:dictionary] = @dictionary
    options[:str] = str

    return @vapi.autocomplete_suggest(options)
  end

  def ensure_correct_suggestions(str, options, results, expected_suggestions)
    sugg = suggestions(str, options)

    phrases = sugg.xpath('//suggestion/phrase')
    results.add_number_equals(expected_suggestions.size,
                              phrases.size, 'suggestion',
                              :verb => 'Returned')

    indexed_phrases = []
    phrases.each_with_index {|x,i| indexed_phrases << [x,i]}
    indexed_phrases.sort! do |(x,i), (y,j)|
      # If the counts are the same
      if (x.parent['count'].to_i <=> y.parent['count'].to_i).zero?
        #  Sort by the phrase text
        x.text <=> y.text
      else
        # Otherwise, "sort" by index, leaving them in place in the array
        i <=> j
      end
    end

    phrases = indexed_phrases.map {|x| x.first}

    phrases.each_with_index do |suggestion, i|
      expected = expected_suggestions[i]
      actual = suggestion.content

      results.add_equals(expected, actual, 'suggestion')
    end
  end

  def ensure_correct_counts(str, options, results, expected_counts)
    sugg = suggestions(str, options)

    suggestions = sugg.xpath('//suggestion')
    results.add_number_equals(expected_counts.size,
                              suggestions.size,
                              'suggestion')

    suggestions.each_with_index do |suggestion, i|
      expected = expected_counts[i]
      actual = suggestion['count'].to_i

      results.add_number_equals(expected, actual, 'time',
                                :verb => 'Suggestion counted')
    end
  end

  def ensure_correct_metadata(query, options, results, expected_metadata)
    data = suggestions(query)
    suggestions = data.xpath('//suggestion')

    results.add_number_equals(expected_metadata.size,
                              suggestions.size,
                              'suggestion')
    indexed_suggestions = []
    suggestions.each_with_index {|x,i| indexed_suggestions << [x,i]}
    indexed_suggestions.sort! do |(x,i), (y,j)|
      # If the counts are the same
      if (x['count'].to_i <=> y['count'].to_i).zero?
        #  Sort by the phrase text
        x.xpath('phrase').first.text <=> y.xpath('phrase').first.text
      else
        # Otherwise, "sort" by index, leaving them in place in the array
        i <=> j
      end
    end

    suggestions = indexed_suggestions.map {|x| x.first}

    suggestions.each_with_index do |suggestion, i|
      expected_meta_hash = expected_metadata[i]
      actual_meta_hash = suggestion_meta_hash(suggestion)

      results.add_number_equals(expected_meta_hash.keys.size,
                                actual_meta_hash.keys.size,
                                'metadata type')

      expected_meta_hash.each do |name, expected_values|
        actual_values = actual_meta_hash[name]

        results.add(! actual_values.nil?,
                    "Found metadata type #{name}",
                    "Could not find metadata type #{name}")

        if actual_values
          # Sorting is OK, as there is no expected order of the metadata
          results.add_equals(expected_values.sort, actual_values.sort,
                             "metadata values for type #{name}")
        end
      end
    end
  end

  private

  def suggestion_meta_hash(suggestion)
    meta_hash = Hash.new

    metas = suggestion.xpath('metadata')
    metas.each do |meta|
      name = meta['name']
      value = meta.content

      values = meta_hash[name]
      if values.nil?
        values = Array.new
        meta_hash[name] = values
      end
      values << [value, meta['count'].to_i]
    end

    return meta_hash
  end

end
