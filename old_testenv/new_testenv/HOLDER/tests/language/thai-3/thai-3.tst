#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'set'
require 'pmap'
require 'misc'
require 'collection'

# Taken from http://www.alanwood.net/unicode/thai.html
THAI_CHARACTERS = {
  'ก' => 'THAI CHARACTER KO KAI  &#3585;',
  'ข' => 'THAI CHARACTER KHO KHAI  &#3586;',
  'ฃ' => 'THAI CHARACTER KHO KHUAT  &#3587;',
  'ค' => 'THAI CHARACTER KHO KHWAI  &#3588;',
  'ฅ' => 'THAI CHARACTER KHO KHON  &#3589;',
  'ฆ' => 'THAI CHARACTER KHO RAKHANG  &#3590;',
  'ง' => 'THAI CHARACTER NGO NGU  &#3591;',
  'จ' => 'THAI CHARACTER CHO CHAN  &#3592;',
  'ฉ' => 'THAI CHARACTER CHO CHING  &#3593;',
  'ช' => 'THAI CHARACTER CHO CHANG  &#3594;',
  'ซ' => 'THAI CHARACTER SO SO  &#3595;',
  'ฌ' => 'THAI CHARACTER CHO CHOE  &#3596;',
  'ญ' => 'THAI CHARACTER YO YING  &#3597;',
  'ฎ' => 'THAI CHARACTER DO CHADA  &#3598;',
  'ฏ' => 'THAI CHARACTER TO PATAK  &#3599;',
  'ฐ' => 'THAI CHARACTER THO THAN  &#3600;',
  'ฑ' => 'THAI CHARACTER THO NANGMONTHO  &#3601;',
  'ฒ' => 'THAI CHARACTER THO PHUTHAO  &#3602;',
  'ณ' => 'THAI CHARACTER NO NEN  &#3603;',
  'ด' => 'THAI CHARACTER DO DEK  &#3604;',
  'ต' => 'THAI CHARACTER TO TAO  &#3605;',
  'ถ' => 'THAI CHARACTER THO THUNG  &#3606;',
  'ท' => 'THAI CHARACTER THO THAHAN  &#3607;',
  'ธ' => 'THAI CHARACTER THO THONG  &#3608;',
  'น' => 'THAI CHARACTER NO NU  &#3609;',
  'บ' => 'THAI CHARACTER BO BAIMAI  &#3610;',
  'ป' => 'THAI CHARACTER PO PLA  &#3611;',
  'ผ' => 'THAI CHARACTER PHO PHUNG  &#3612;',
  'ฝ' => 'THAI CHARACTER FO FA  &#3613;',
  'พ' => 'THAI CHARACTER PHO PHAN  &#3614;',
  'ฟ' => 'THAI CHARACTER FO FAN  &#3615;',
  'ภ' => 'THAI CHARACTER PHO SAMPHAO  &#3616;',
  'ม' => 'THAI CHARACTER MO MA  &#3617;',
  'ย' => 'THAI CHARACTER YO YAK  &#3618;',
  'ร' => 'THAI CHARACTER RO RUA  &#3619;',
  'ฤ' => 'THAI CHARACTER RU  &#3620;',
  'ล' => 'THAI CHARACTER LO LING  &#3621;',
  'ฦ' => 'THAI CHARACTER LU  &#3622;',
  'ว' => 'THAI CHARACTER WO WAEN  &#3623;',
  'ศ' => 'THAI CHARACTER SO SALA  &#3624;',
  'ษ' => 'THAI CHARACTER SO RUSI  &#3625;',
  'ส' => 'THAI CHARACTER SO SUA  &#3626;',
  'ห' => 'THAI CHARACTER HO HIP  &#3627;',
  'ฬ' => 'THAI CHARACTER LO CHULA  &#3628;',
  'อ' => 'THAI CHARACTER O ANG  &#3629;',
  'ฮ' => 'THAI CHARACTER HO NOKHUK  &#3630;',
  'ฯ' => 'THAI CHARACTER PAIYANNOI  &#3631;',
  'ะ' => 'THAI CHARACTER SARA A  &#3632;',
  'ั' => 'THAI CHARACTER MAI HAN-AKAT &#3633;',
  'า' => 'THAI CHARACTER SARA AA  &#3634;',
  'ำ' => 'THAI CHARACTER SARA AM  &#3635;',
  'ิ' => 'THAI CHARACTER SARA I &#3636;',
  'ี' => 'THAI CHARACTER SARA II &#3637;',
  'ึ' => 'THAI CHARACTER SARA UE &#3638;',
  'ื' => 'THAI CHARACTER SARA UEE &#3639;',
  'ุ' => 'THAI CHARACTER SARA U &#3640;',
  'ู' => 'THAI CHARACTER SARA UU &#3641;',
  'ฺ' => 'THAI CHARACTER PHINTHU &#3642;',
  '฿' => 'THAI CURRENCY SYMBOL BAHT  &#3647;',
  'เ' => 'THAI CHARACTER SARA E  &#3648;',
  'แ' => 'THAI CHARACTER SARA AE  &#3649;',
  'โ' => 'THAI CHARACTER SARA O  &#3650;',
  'ใ' => 'THAI CHARACTER SARA AI MAIMUAN  &#3651;',
  'ไ' => 'THAI CHARACTER SARA AI MAIMALAI  &#3652;',
  'ๅ' => 'THAI CHARACTER LAKKHANGYAO  &#3653;',
  'ๆ' => 'THAI CHARACTER MAIYAMOK  &#3654;',
  '็' => 'THAI CHARACTER MAITAIKHU &#3655;',
  '่' => 'THAI CHARACTER MAI EK &#3656;',
  '้' => 'THAI CHARACTER MAI THO &#3657;',
  '๊' => 'THAI CHARACTER MAI TRI &#3658;',
  '๋' => 'THAI CHARACTER MAI CHATTAWA &#3659;',
  '์' => 'THAI CHARACTER THANTHAKHAT &#3660;',
  'ํ' => 'THAI CHARACTER NIKHAHIT &#3661;',
  '๎' => 'THAI CHARACTER YAMAKKAN &#3662;',
  '๏' => 'THAI CHARACTER FONGMAN  &#3663;',
# As of 7.5-6, Velocity does not segment on Thai digits.
# What Velocity *should* do with Thai digits is not specified.
# '๐' => 'THAI DIGIT ZERO  &#3664;',
# '๑' => 'THAI DIGIT ONE  &#3665;',
# '๒' => 'THAI DIGIT TWO  &#3666;',
# '๓' => 'THAI DIGIT THREE  &#3667;',
# '๔' => 'THAI DIGIT FOUR  &#3668;',
# '๕' => 'THAI DIGIT FIVE  &#3669;',
# '๖' => 'THAI DIGIT SIX  &#3670;',
# '๗' => 'THAI DIGIT SEVEN  &#3671;',
# '๘' => 'THAI DIGIT EIGHT  &#3672;',
# '๙' => 'THAI DIGIT NINE  &#3673;',
  '๚' => 'THAI CHARACTER ANGKHANKHU  &#3674;',
  '๛' => 'THAI CHARACTER KHOMUT  &#3675;'}

THAI_PUNCTUATION = Set.new(['฿', '๏', '๚', '๛'])

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/%s">
    <crawl-data content-type="text/plain" encoding="utf-8">%s</crawl-data>
  </crawl-url>
</crawl-urls>'

# Reset the random number generator
srand(1)
LETTERS = 'abcdefghijklmnopqrstuvwxyz'
def pseudoword
  (0..6).map {LETTERS[rand(LETTERS.length),1]}.join
end

results = TestResults.new('Thai handling by the mixed segmenter.',
                          '"abc...def"',
                          'Where ... is any thai character should index "abc"',
                          '"def" and each character of the thai individually.')

collection = Collection.new('thai-3')
results.associate(collection)
collection.delete
collection.create('default-push')
# Turn on the mixed segmenter. I need to make a cleaner way to do this.
xml = collection.xml
streams_func = xml.xpath('//vse-index-streams/call-function').first
child = streams_func.add_child(Nokogiri::XML::Node.new('with', xml))
child['name'] = 'segmenter'
child.content = 'mixed'
collection.set_xml(xml)

word_triples = THAI_CHARACTERS.keys.sort.map {|thai_char|
  [pseudoword, thai_char, pseudoword]
}

# Put a few non-Thai documents into the index.
['one', 'two', 'three'].each {|word|
  collection.enqueue_xml(CRAWL_NODES % [word, word])
}

# We do the Thai enqueues in parallel (just to reduce run-time)
enqueue_results = word_triples.pmap {|word1, thai_char, word2|
  mixed_word = word1 + thai_char + word2
  Collection.new('thai-3').enqueue_xml(CRAWL_NODES % [mixed_word, mixed_word])
}

results.add(enqueue_results.all?, 'Enqueues completed.')

# and do the queries in parallel:
query_results = word_triples.flatten.pmap {|word|
  qr = Collection.new('thai-3').search(word)
  [word, qr.xpath('/query-results/added-source/@total-results-with-duplicates').
            first.to_s.to_i]
}

n_docs = collection.index_n_docs

msg 'Searches complete. Most searches should find a single document.'
msg "Punctuation, #{THAI_PUNCTUATION.to_a.join(', ')}, should match all #{n_docs} docs."

query_results.each {|word, count|
  expect = 1
  expect = n_docs if THAI_PUNCTUATION.member?(word)
  results.add_number_equals(expect, count,
              '"%s" %s' % [word, THAI_CHARACTERS[word]])
}

results.cleanup_and_exit!
