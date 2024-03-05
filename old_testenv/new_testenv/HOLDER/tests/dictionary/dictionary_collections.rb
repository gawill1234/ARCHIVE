# -*- coding: utf-8 -*-
require 'misc'
require 'collection'

class DictionaryCollection < Collection
  def initialize(name)
    super(name)
  end

  def setup
    reset_collection
    enqueue_collection_data
  end

  def reset_collection
    delete
    create('default-push')
  end

  def enqueue_documents(xml_str)
    xml = Nokogiri::XML(xml_str)
    xml_doc = xml.document

    xml.xpath('//document').each_with_index do |doc, doc_n|
      cd = xml_doc.create_element('crawl-data')
      cd['encoding'] = 'xml'
      cd['content-type'] = 'application/vxml'
      cd << doc

      cu = xml_doc.create_element('crawl-url')
      cu['url'] = "http://127.0.0.1/#{doc_n}"
      cu['synchronization'] = 'indexed'
      cu['status'] = 'complete'
      cu << cd

      enqueue_xml(cu)
    end
  end

  def enqueue_phrases(phrases)
    xml_doc = Nokogiri::XML::Document.new
    xml_doc.extend(ContentExtension)

    phrases.each do |phrase|
      doc = xml_doc.create_element('document')

      content = xml_doc.create_content('title')
      content.content = phrase
      doc << content

      cd = xml_doc.create_element('crawl-data')
      cd['encoding'] = 'xml'
      cd['content-type'] = 'application/vxml'
      cd << doc

      cu = xml_doc.create_element('crawl-url')
      cu['url'] = "http://127.0.0.1/#{phrase}"
      cu['synchronization'] = 'indexed'
      cu['status'] = 'complete'
      cu << cd

      enqueue_xml(cu)
    end
  end
end

module RadioAlphabet
  RADIO_ALPHABET = [
    "alpha","bravo","charlie","delta","echo",
    "foxtrot","golf","hotel","india","juliet",
    "kilo","lima","mike","november","oscar",
    "papa","quebec","romeo","sierra","tango",
    "uniform","victor","whiskey","xray","yankee","zulu"
  ].freeze
end

module ContentExtension
  def create_content(name)
    content = create_element('content')
    content['name'] = name
    content['type'] = 'text'
    content
  end
end

class DictionarySimple < DictionaryCollection
  include RadioAlphabet

  def initialize
    super('dictionary-simple')
  end

  def enqueue_collection_data
    xml_doc = Nokogiri::XML::Document.new
    xml_doc.extend(ContentExtension)

    10.times do |doc_n|
      text = ""
      acl = ""

      content = xml_doc.create_content('title')
      10.times do |word_n|
        word = RADIO_ALPHABET[(doc_n * word_n) % RADIO_ALPHABET.size]
        text << "#{word} "
      end
      content.content = text.strip

      3.times do |i|
        acl << "#{doc_n + i}\n"
      end
      content['acl'] = acl.strip

      doc = xml_doc.create_element('document')
      doc << content

      content = xml_doc.create_content('count')
      count = "#{10 - doc_n}"
      content.content = count.strip
      doc << content

      cd = xml_doc.create_element('crawl-data')
      cd['encoding'] = 'xml'
      cd['content-type'] = 'application/vxml'
      cd << doc

      cu = xml_doc.create_element('crawl-url')
      cu['url'] = "http://127.0.0.1/#{doc_n}"
      cu['synchronization'] = 'indexed'
      cu['status'] = 'complete'
      cu << cd

      enqueue_xml(cu)
    end
  end
end

class DictionaryLarge < DictionaryCollection
  include RadioAlphabet

  def initialize
    super('dictionary-large')
  end

  def enqueue_collection_data
    xml_doc = Nokogiri::XML::Document.new
    xml_doc.extend(ContentExtension)

    # Want about 1 MiB of data
    shortest_word = RADIO_ALPHABET.sort_by(&:length).first.length
    approx_count = ((1024*1024) / shortest_word)

    RADIO_ALPHABET.each do |word|
      doc = xml_doc.create_element('document')

      content = xml_doc.create_content('title')
      content.content = word
      doc << content

      content = xml_doc.create_content('snippet')
      content.content = ([word] * approx_count).join(' ')
      doc << content

      cd = xml_doc.create_element('crawl-data')
      cd['encoding'] = 'xml'
      cd['content-type'] = 'application/vxml'
      cd << doc

      cu = xml_doc.create_element('crawl-url')
      cu['url'] = "http://127.0.0.1/#{word}"
      cu['synchronization'] = 'indexed'
      cu['status'] = 'complete'
      cu << cd

      enqueue_xml(cu)
    end
  end
end

class DictionaryMetadata < DictionaryCollection
  def initialize
    super('dictionary-metadata')
  end

  def enqueue_collection_data
    xml_str = <<EOF
<a>
<document>
  <content name="title">alpha</content>
  <content name="author">Alice</content>
  <content name="genre">Mystery</content>
  <content name="count">3</content>
</document>
<document>
  <content name="title">beta</content>
  <content name="author">Bob</content>
  <content name="author">Betty</content>
  <content name="genre">Comedy</content>
  <content name="count">5</content>
</document>
<document>
  <content name="important">true</content>
  <content name="author">Carl</content>
  <content name="genre">Fantasy</content>
  <content name="count">9</content>
</document>
<document>
  <content name="title">omega</content>
  <content name="author">Otto</content>
  <content name="genre">Horror</content>
  <content name="count">17</content>
</document>
<document>
  <content name="title">omicron</content>
  <content name="author">Otto</content>
  <content name="genre">Horror</content>
  <content name="count">13</content>
</document>
</a>
EOF

    enqueue_documents(xml_str)
  end
end

class DictionaryCanonical < DictionaryCollection
  def initialize
    super('dictionary-canonical')
  end

  def enqueue_collection_data
    xml_str = <<EOF
<a>
<document>
  <content name="email">joe@blah.com</content>
  <content name="contact">Joe User</content>
</document>
<document>
  <content name="email">JOE@BLAH.COM</content>
  <content name="contact">JOE USER</content>
</document>
<document>
  <content name="email">president@whitehouse.gov</content>
  <content name="contact">Barack Obama</content>
</document>
</a>
EOF

    enqueue_documents(xml_str)
  end
end

class DictionaryHTMLEscaping < DictionaryCollection
  def initialize
    super('dictionary-html-escaping')
  end

  def enqueue_collection_data
    xml_str = <<EOF
<a>
<document>
  <content name="name" type="text">&amp;</content>
  <content name="name" type="html">&amp;</content>
</document>
<document>
  <content name="name" type="text">&lt;</content>
  <content name="name" type="html">&lt;</content>
</document>
<document>
  <content name="name" type="text">&gt;</content>
  <content name="name" type="html">&gt;</content>
</document>
<document>
  <content name="name" type="text">&apos;</content>
  <content name="name" type="html">&apos;</content>
</document>
<document>
  <content name="name" type="text">&quot;</content>
  <content name="name" type="html">&quot;</content>
</document>
<document>
  <content name="name" type="text">&#10;</content>
  <content name="name" type="html">&#10;</content>
</document>
<document>
  <content name="name" type="text">&#160;</content>
  <content name="name" type="html">&#160;</content>
</document>
</a>
EOF

    enqueue_documents(xml_str)
  end
end

class DictionaryPolyglot < DictionaryCollection
  def initialize
    super('dictionary-canonical')
  end

  def enqueue_collection_data
    xml_str = <<EOF
<a>
<document>
  <content name="phrase">École Normale Supérieure</content>
  <content name="word">Ecole</content>
</document>
<document>
  <content name="phrase">Dansen går till Hårgalåten</content>
  <content name="word">Hargalaten</content>
</document>
<document>
  <content name="phrase">bím i gcónai i do theannta</content
  <content name="word">bím</content>
</document>
<document>
  <content name="phrase">somoruː vɒʃaːrnɒp</content>
  <content name="word">vɒʃaːrnɒp</content>
</document>
<document>
  <content name="phrase">ᚦᚩᚱᚾ᛫ᛒᛦᚦ᛫ᚦᛖᚪᚱᛚᛖ᛫ᛋᚳᛖᚪᚱᛈ</content>
  <content name="word">ᚦᚩᚱᚾ</content>
</document>
<document>
  <content name="phrase">ვეპხის ტყაოსანი შოთა რუსთაველი</content>
  <content name="word">ტყაოსანი</content>
</document>
<document>
  <content name="phrase">국내 검색 엔진</content>
  <content name="word">국내검색엔진</content>
</document>
<document>
  <content name="phrase">あなた の 単語 リスト</content>
  <content name="word">あなたの単語リスト</content>
</document>
<document>
  <content name="phrase">中餐 小議</content>
  <content name="word">中餐小議</content>
</document>
<document>
  <content name="phrase">สถานี อวกาศ นานา ชาติ</content>
  <content name="word">สถานีอวกาศนานาชาติ</content>
</document>
</a>
EOF

    enqueue_documents(xml_str)
  end
end
