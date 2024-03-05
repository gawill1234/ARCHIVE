require 'misc'
require 'velocity/repository'

class BaseFilter
  attr_reader :name

  def initialize(name)
    @repo = Repository.new
    @name = name
  end

  def delete
    @repo.delete('filter', name)
  end

  def setup
    @repo.delete('filter', name)
    @repo.add(filter_xml)
  end
end

class FooFilter < BaseFilter
  def initialize
    super('autocomplete-foo-filter')
  end

  def filter_xml
    <<EOF
<filter name="#{name}">
  <filter-term>foo</filter-term>
</filter>
EOF
  end
end

class BarFilter < BaseFilter
  def initialize
    super('autocomplete-bar-filter')
  end

  def filter_xml
    <<EOF
<filter name="#{name}">
  <filter-term>bar</filter-term>
</filter>
EOF
  end
end
