#!/usr/bin/env ruby

require 'collection'
require 'config'


def base_collection
  bcol = Collection.new('data-export-0')
  # Load my base collection
  unless bcol.exists?
    bc = Broker_Config.new
    was = bc.get
    bc.set
    status = system '$TEST_ROOT/tests/collection-broker/tunable.py' +
      ' -q1 -c1 -z10000 -n50 -e50 -Ndata-export-' +
      ' --dictionary $TEST_ROOT/files/top_20k_words'
    bc.set(was)
  end
  bcol
end


def export_node(vapi, export_id)
  vapi.collection_broker_status.xpath('/collection-broker-status-response/export[@id="%s"]' % export_id).first
end


def export_status(vapi, export_id)
  node = export_node(vapi, export_id)
  if node.nil?
    node
  else
    node['status'].to_s
  end
end


def wait_for_export(vapi, export_id)
  while (status = export_status(vapi, export_id)) != 'complete' do
    msg "export status is '#{status}'"
    if status == 'error'
      msg "Export ended with error:"
      msg export_node(vapi, export_id)
      return false
    end
    sleep 15 - (Time.new.to_f % 15)
  end
  true
end


def do_export(source, target, options={})
  export_id = source.export_data(target.name, options)
  wait_for_export(source.vapi, export_id)
end

alias copy_collection do_export

class Export_Checker
  WORD_FILE = ENV['TEST_ROOT']+ '/files/top_20k_words'
  WORDS = File.open(WORD_FILE) {|f| f.map {|l| l.strip}}

  attr_reader :words, :original_counts, :target_counts

  def initialize(source, target, query=nil)
    @source = source
    @target = target
    @query = query
    @words = check_words
    @original_counts = nil
  end

  def check_words(n=32)
    Array.new(n).map { WORDS[rand(WORDS.length)] }
  end

  def export(options={})
    if @query
      do_export(@source, @target, options.merge(:query => @query))
    else
      do_export(@source, @target, options)
    end
  end

  def get_counts(collection, query=nil)
    @words.map do |word|
      if query
        collection.broker_search(:query => (query + ' ' + word))
      else
        collection.broker_search(:query => word)
      end
    end
  end

  def gather_original_counts
    @original_counts = get_counts(@source, @query)
  end

  def check_target_counts
    begin
      target_n = @target.broker_search
    rescue => ex
      msg "Cannot search the target collection #{@target.name}:"
      msg ex
      return false
    end
    raise "Can't check target counts without gathering original counts." if
      @original_counts.nil?

    @target_counts = get_counts(@target)
    if @original_counts == @target_counts
      true
    else
      @words.length.times do |i|
        if @original_counts[i] != @target_counts[i]
          msg('Mismatch: %d in %s and %d in %s for "%s"' %
              [@original_counts[i], @source.name,
               @target_counts[i], @target.name,
               @words[i]])
        end
      end
      false
    end
  end
end
