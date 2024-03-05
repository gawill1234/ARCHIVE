require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'multistream_indexing_helper'

# This test assumes existence of special collections stored in the qa shared namespace, i.e:
# language-detection-test
# stream-test-default
# secondary-streams
# stream-test-num-chars-minus1
# stream-test-num-chars-0
# stream-test-num-chars-100
# stream-test-num-chars-1M
# global-indexing-options-lang-indexing-disabled
# global-indexing-options-lang-indexing-enabled

###################################################################
# These are labeled with cases described in
# https://meta.vivisimo.com/wiki/Multistream_Indexing/Test_Plan
# Tests with specific language queries are at the end
###################################################################

language_detection = 'language-detection-test'
default_stream = 'stream-test-default'
secondary_streams = 'secondary-streams'
no_min_limit_neg1 = 'stream-test-num-chars-minus1'
no_min_limit_zero = 'stream-test-num-chars-0'
min_limit_100 = 'stream-test-num-chars-100'
min_limit_1m = 'stream-test-num-chars-1M'
language_indexing_disabled = 'global-indexing-options-lang-indexing-disabled'
language_indexing_enabled = 'global-indexing-options-lang-indexing-enabled'

# Todo: add some negative tests, eg search for chinese and confirm that there are no contents with thai streams?

describe "Multi-stream indexing: " do

  vlog "Running tests for multi-stream indexing"

  context "Verifying specific language indexing options enabled in the normalization converter" do

    before(:all) do
      multistream_setup(language_detection)
    end

    it "should have one chinese doc that uses the chinese stream on its snippet" do
      confirm_num_results(language_detection, "language:chinese", "1")
      confirm_vse_stream(language_detection, "language:chinese", "//list/document[1]/content[@name='snippet']", "2")
    end

    it "should have two japanese docs and the second should use the japanese stream on its snippet and the chinese stream on its title" do
      confirm_num_results(language_detection, "language:japanese", "2")
      confirm_vse_stream(language_detection, "language:japanese", "//list/document[2]/content[@name='snippet']", "3")
      confirm_vse_stream(language_detection, "language:japanese", "//list/document[2]/content[@name='title']", "2")
    end

    it "should have one korean doc that uses the korean stream on its snippet" do
      confirm_num_results(language_detection, "language:korean", "1")
      confirm_vse_stream(language_detection, "language:korean", "//list/document[1]/content[@name='snippet']", "4")
    end

    it "should have two thai docs and the first should use the thai stream on its snippet" do
      confirm_num_results(language_detection, "language:thai", "2")
      confirm_vse_stream(language_detection, "language:thai", "//list/document[1]/content[@name='snippet']", "5")
    end

    # Extra tests to make sure that different language segmentation applies as expected
    it "should retrieve two chinese docs on a traditional chinese character search" do
      confirm_num_results(language_detection, "的", "2")
      confirm_language(language_detection, "的", "//list/document[1]", "chinese")
    end

    it "should retrieve two japanese docs on search of a japanese word" do
      confirm_num_results(language_detection, "氏の", "2")
      confirm_language(language_detection, "氏の", "//list//document[1]", "japanese")

    end

    it "should retrieve two korean docs on search of a korean phrase" do
      confirm_num_results(language_detection, "엔진", "2")
      confirm_language(language_detection, "엔진", "//list//document[1]", "korean")
    end

    it "should retrieve two thai docs on search of a thai word" do
      confirm_num_results(language_detection, "พระ", "2")
      confirm_language(language_detection, "พระ", "//list//document[1]", "thai")
    end

    it "should retrieve one korean doc on search of a chinese word that appears in that korean document" do
      confirm_num_results(language_detection, "故", "1")
      confirm_language(language_detection, "故", "//list//document[1]", "korean")
    end

    it "should retrieve one chinese, one korean, and one japanese doc on a search of a chinese character that appears in all 3" do
      confirm_num_results(language_detection, "前", "3")
      confirm_language(language_detection, "前", "//list//document[1]", "chinese")
      confirm_language(language_detection, "前", "//list//document[2]", "korean")
      confirm_language(language_detection, "前", "//list//document[3]", "japanese")
    end

    it "should retrieve one korean document on a search of a chinese character that appears in it" do
      confirm_num_results(language_detection, "교수", "1")
      confirm_language(language_detection, "교수", "//list//document[1]", "korean")
    end

  end

  context "Verifying that when language indexing is disabled, the default stream applies to all contents" do

    before(:all) do
      multistream_setup(default_stream)
    end

    it "should have two japanese docs" do
      confirm_num_results(default_stream, "language:japanese", "2")
    end

    it "should use the default stream on the 1st japanese document's snippet" do
      confirm_vse_stream(default_stream, "language:japanese", "//list/document[1]/content[@name='snippet']", "2")
    end

  end

  context  "Verifying that custom language specific indexing options work when enabled in the normalization converter, and that secondary streams are applied appropriately" do

    before(:all) do
      multistream_setup(secondary_streams)
    end

    it "should have one chinese doc that uses the custom chinese stream on its snippet" do
      confirm_num_results(secondary_streams, "language:chinese", "1")
      confirm_vse_stream(secondary_streams, "language:chinese", "//list/document[1]/content[@name='snippet']", "2")
    end

    it "should have two japanese documents and the first document's snippet should use the custom japanese stream" do
      confirm_num_results(secondary_streams, "language:japanese", "2")
      confirm_vse_stream(secondary_streams, "language:japanese", "//list/document[1]/content[@name='snippet']", "3 4")
    end

    it "should have one korean document and the first document's snippet should use the custom korean stream" do
      confirm_num_results(secondary_streams, "language:korean", "1")
      confirm_vse_stream(secondary_streams, "language:korean", "//list/document[1]/content[@name='snippet']", "5 4 6")
    end

    it "should be using the depluralize stemmer in the primary stream for korean" do
      # do a search for secret, the document contains secrets
      confirm_num_results(secondary_streams, "secret", "1")
      confirm_vse_stream(secondary_streams, "secret", "//list/document[1]/content[@name='snippet']", "5 4 6")
    end

    it "should be using the english stemmer in the secondary stream for korean" do
      # do a search for bin, the document contains binning
      confirm_num_results(secondary_streams, "bin", "1")
      confirm_vse_stream(secondary_streams, "bin", "//list/document[1]/content[@name='snippet']", "5 4 6")
    end

    it "should be using the english knowledge base in the tertiary stream for korean" do
      # do a search for covert, the document contains secrets
      confirm_num_results(secondary_streams, "covert", "1")
      confirm_vse_stream(secondary_streams, "covert", "//list/document[1]/content[@name='snippet']", "5 4 6")
    end

    it "should have 2 thai documents and the first document's snippet should be using the custom thai stream" do
      confirm_num_results(secondary_streams, "language:thai", "2")
      confirm_vse_stream(secondary_streams, "language:thai", "//list/document[1]/content[@name='snippet']", "7")
    end

    it "should have 5 english documents" do
      confirm_num_results(secondary_streams, "language:english", "5")
    end

    it "should use the default stream for an english content shorter than 40 characters" do
      confirm_vse_stream(secondary_streams, "language:english", "//list/document[1]/content[@name='title']", "2")
    end

    it "should use the custom english stream for an english content greater than 40 characters" do
      confirm_vse_stream(secondary_streams, "language:english", "//list/document[1]/content[@name='snippet']", "8 9")
    end

    it "should not use the custom english stream on a spanish document" do
      # there is a spanish document that contains the word jumping that would only be retrieved if it was indexed using the english stemmer
      confirm_num_results(secondary_streams, "jump", "0")
    end

    it "should use the collection's default stream for contents whose language could not be detected" do
      confirm_num_results(secondary_streams, "language:unknown", "3")
      confirm_vse_stream(secondary_streams, "language:unknown", "//list/document[1]/content[@name='snippet']", "2")
    end
  end

  context "Verify that setting the min number of characters to -1 for language specific indexing works" do

    before(:all) do
      multistream_setup(no_min_limit_neg1)
    end

    it "should apply the default stream to english contents of any size" do
      confirm_num_results(no_min_limit_neg1, "language:english", "5")
      confirm_vse_stream(no_min_limit_neg1, "language:english", "//list/document[1]/content[@name='title']", "2")
    end

  end

  context "Verify that setting the min number of characters to 0 for language specific indexing works" do

    before(:all) do
      multistream_setup(no_min_limit_zero)
    end

    it "should apply the default stream to english contents of any size" do
      confirm_num_results(no_min_limit_zero, "language:english", "5")
      confirm_vse_stream(no_min_limit_zero, "language:english", "//list/document[1]/content[@name='title']", "2")
    end

  end

  context "Verify that setting the min number of characters to 100 for language specific indexing works" do

    before(:all) do
      multistream_setup(min_limit_100)
    end

    it "should apply the thai stream to long thai contents" do
      confirm_num_results(min_limit_100, "language:thai", "2")
      confirm_vse_stream(min_limit_100, "language:thai", "//list/document[2]/content[@name='snippet']", "4")
    end

    it "should apply the default stream to short korean contents" do
      # the 2nd "thai" document has a korean title
      confirm_vse_stream(min_limit_100, "language:thai", "//list/document[2]/content[@name='title']", "2")
    end
  end

  context "Verify that setting the min character limit really high prevents language specific indexing" do

    before(:all) do
      multistream_setup(min_limit_1m)
    end

    it "should use the default stream on all contents" do
      confirm_num_results(min_limit_1m, "language:thai", "2")
      confirm_vse_stream(min_limit_1m, "language:thai", "//list/document[1]/content[@name='snippet']", "2")
    end

  end

  context "Verify that globally defined indexing options are used when language specific indexing is disabled" do

    before(:all) do
      multistream_setup(language_indexing_disabled)
    end

    it "should use the default stream on all contents" do
      confirm_num_results(language_indexing_disabled, "", "24")
      confirm_vse_stream(language_indexing_disabled, "", "//list/document[1]/content[@name='snippet']", "2 3 4")
    end

  end

  context "Verify that globally defined indexing options will only be used for languages that do not have associated custom streams" do

    before(:all) do
      multistream_setup(language_indexing_enabled)
    end

    it "should apply default streams to english contents" do
      confirm_num_results(language_indexing_enabled, "language:english", "5")
      confirm_vse_stream(language_indexing_enabled, "language:english", "//list/document[1]/content[@name='snippet']", "2 3 4")
    end

    it "should apply default streams to unknown language contents" do
      confirm_num_results(language_indexing_enabled, "language:unknown", "3")
      confirm_vse_stream(language_indexing_enabled, "language:unknown", "//list/document[1]/content[@name='snippet']", "2 3 4")
    end

    it "should apply chinese streams to chinese contents" do
      confirm_num_results(language_indexing_enabled, "language:chinese", "1")
      confirm_vse_stream(language_indexing_enabled, "language:chinese", "//list/document[1]/content[@name='snippet']", "2")
    end

    it "should apply japanese streams to japanese contents" do
      confirm_num_results(language_indexing_enabled, "language:japanese", "2")
      confirm_vse_stream(language_indexing_enabled, "language:japanese", "//list/document[1]/content[@name='snippet']", "5")
    end

    it "should apply korean streams to korean contents" do
      confirm_num_results(language_indexing_enabled, "language:korean", "1")
      confirm_vse_stream(language_indexing_enabled, "language:korean", "//list/document[1]/content[@name='snippet']", "6")
    end

    it "should apply thai streams to thai contents" do
      confirm_num_results(language_indexing_enabled, "language:thai", "2")
      confirm_vse_stream(language_indexing_enabled, "language:thai", "//list/document[1]/content[@name='snippet']", "7")
    end

  end
	
end
