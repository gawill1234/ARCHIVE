require 'collection'

class ExampleMetadata < Collection
  def initialize(velocity=TESTENV.velocity,
                 user=TESTENV.user,
                 password=TESTENV.password)
    super('example-metadata', velocity, user, password)
  end

  def ensure_correctness
    unless is_correct?
      rebuild_collection

      raise "Collection example-metadata can not be reset to the correct state" unless is_correct?
    end
  end

  private

  def is_correct?
    return false unless exists?

    stat_xml = status

    crawler_stat = stat_xml.xpath('//crawler-status').first
    return false if crawler_stat.nil?
    return false unless crawler_stat['n-input'] == "44"
    return false unless crawler_stat['n-output'] == "44"
    return false unless crawler_stat['n-errors'] == "0"

    indexer_stat = stat_xml.xpath('//vse-index-status').first
    return false if indexer_stat.nil?
    return false unless indexer_stat['n-docs'] == "43"

    return true
  end

  def rebuild_collection
    delete
    # no need to create - internal node

    crawler_start
    wait_until_idle
  end
end
