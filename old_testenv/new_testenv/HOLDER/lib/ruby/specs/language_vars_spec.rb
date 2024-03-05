require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'language_vars_helper'

describe "Project language variables" do
  vlog "** Running tests for project language variables\n***********************************************"
    context "Verifying that high-level language variables in the project correctly instantiate low-level clustering variables" do
      before(:all) do
         language_vars_test_setup('example-metadata')
      end

    it "should have the same defaults as before" do
        vlog "Project: exqa-lang-vars-default"
        confirm_stem_and_stoplist_value('exqa-lang-vars-default', 'delanguage+english+depluralize', 'core+web+english+custom')
    end

    it "(language.main=english) should have same defaults as before" do
        confirm_stem_and_stoplist_value('exqa-lang-vars-english', 'delanguage+english+depluralize', 'core+web+english+custom')
    end

    it "language.main=english and other=spanish should instantiate to" do
        confirm_stem_and_stoplist_value('exqa-lang-vars-english-spanish', 'delanguage+english+spanish+depluralize', 'core+web+spanish+english+custom')
    end

    it "language.main=english and other=japanese should instantiate to" do
        confirm_stem_and_stoplist_value('exqa-lang-vars-english-japanese', 'delanguage+english+depluralize', 'core+web+japanese-letters+japanese+english+custom')
     end

     it "language.main=english and other=japanese+thai should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-english-japanese-thai', 'japanese', 'delanguage+english+depluralize', 'core+web+japanese-letters+japanese+thai+english+custom')
     end

     it "language.main=english and other=chinese should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-english-chinese', 'mixed', 'delanguage+english+depluralize', 'core+web+chinese+english+custom')
     end

     it "language.main=english and other=chinese+thai should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-english-chinese-thai', 'mixed', 'delanguage+english+depluralize', 'core+web+chinese+thai+english+custom')
     end

     it "language.main=english and other=thai+chinese should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-english-thai-chinese', 'mixed', 'delanguage+english+depluralize', 'core+web+thai+chinese+english+custom')
     end

     it "language.main=english and other=all other langs instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-english-plus-others', 'mixed', 'delanguage+english+arabic+danish+dutch+finnish+french+german+hebrew+italian+korean+norwegian+portuguese+russian+spanish+swedish+turkish+depluralize', 'core+web+arabic+chinese+danish+dutch+farsi+french+german+hebrew+italian+japanese-letters+japanese+korean+polish+portuguese+russian+spanish+swedish+thai+english+custom')
     end
  
     it "language.main=english and domain kbs should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-english-domain-kbs', 'delanguage+english+depluralize', 'core+web+english+business+computers+core+custom+drugs+email+government+medicine+news')
     end

     it "language.main=english, other=russian and all domain kbs should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-english-russian-domain-kbs', 'delanguage+english+russian+depluralize', 'core+web+russian+english+ads+business+chemistry+computers+core+csol+custom+doc-search-kb+drugs+email+government+medicine+news+patents+physics+science+shopping+support+unbreak-span')
     end

     it "language.main=spanish, other=english should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-spanish-english', 'delanguage+spanish+english+spanish-depluralize', 'core+web+english+spanish+custom')
      end

     it "language.main=spanish, other=italian should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-spanish-italian', 'delanguage+spanish+italian+spanish-depluralize', 'core+web+italian+spanish+custom')
     end

     it "language.main=spanish, other=japanese should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-spanish-japanese', 'japanese', 'delanguage+spanish+spanish-depluralize', 'core+web+japanese-letters+japanese+spanish+custom')
     end

     it "language.main=spanish, other=all other langs should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-spanish-plus-others', 'delanguage+spanish+arabic+danish+dutch+english+finnish+french+german+hebrew+italian+korean+norwegian+portuguese+russian+swedish+turkish+spanish-depluralize', 'core+web+arabic+chinese+danish+dutch+english+farsi+french+german+hebrew+italian+japanese-letters+japanese+korean+polish+portuguese+russian+swedish+thai+spanish+custom')
     end

     it "language.main=japanese should instantiate to" do 
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-japanese', 'japanese', 'delanguage+english+depluralize', 'core+web+english+japanese-letters+japanese+custom')
     end

     it "language.main=japanese, other=chinese should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-japanese-chinese', 'japanese', 'delanguage+english+depluralize', 'core+web+english+chinese+japanese-letters+japanese+custom')
     end

     it "language.main=japanese, other=chinese+thai should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-japanese-chinese-thai', 'japanese', 'delanguage+english+depluralize', 'core+web+english+chinese+thai+japanese-letters+japanese+custom')
     end

     it "language.main=japanese, other=english should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-japanese-english', 'japanese', 'delanguage+english+depluralize', 'core+web+english+japanese-letters+japanese+custom')
     end

     it "language.main=japanese, other=french should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-japanese-french', 'japanese', 'delanguage+french+depluralize', 'core+web+french+japanese-letters+japanese+custom')
     end

     it "language.main=japanese, other=all other langs should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-japanese-plus-others', 'japanese', 'delanguage+arabic+danish+dutch+english+finnish+french+german+hebrew+italian+korean+norwegian+portuguese+russian+spanish+swedish+turkish+depluralize', 'core+web+arabic+chinese+danish+dutch+english+farsi+french+german+hebrew+italian+korean+polish+portuguese+russian+spanish+swedish+thai+japanese-letters+japanese+custom')
     end

     it "language.main=chinese should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-chinese', 'mixed', 'delanguage+english+depluralize', 'core+web+english+chinese+custom')
     end

     it "language.main=chinese, other=english should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-chinese-english', 'mixed', 'delanguage+english+depluralize', 'core+web+english+chinese+custom')
     end

     it "language.main=chinese, other=russian should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-chinese-russian', 'mixed', 'delanguage+russian+depluralize', 'core+web+russian+chinese+custom')
     end

     it "language.main=chinese, other=thai+japanese should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-chinese-thai-japanese', 'mixed', 'delanguage+english+depluralize', 'core+web+english+thai+japanese-letters+japanese+chinese+custom')
     end

     it "language.main=chinese, other=all other langs should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-chinese-plus-others', 'mixed', 'delanguage+arabic+danish+dutch+english+finnish+french+german+hebrew+italian+korean+norwegian+portuguese+russian+spanish+swedish+turkish+depluralize', 'core+web+arabic+danish+dutch+english+farsi+french+german+hebrew+italian+japanese-letters+japanese+korean+polish+portuguese+russian+spanish+swedish+thai+chinese+custom')
     end

     it "language.main=thai should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-thai', 'thai', 'delanguage+english+depluralize', 'core+web+english+thai+custom')
     end

     it "language.main=thai other=french should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-thai-french', 'thai', 'delanguage+french+depluralize', 'core+web+french+thai+custom')
     end

     it "language.main=thai other=japanese+chinese should instantiate to" do
       confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-thai-japanese-chinese', 'thai', 'delanguage+english+depluralize', 'core+web+english+japanese-letters+japanese+chinese+thai+custom')
     end

     it "language.main=norwegian should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-norwegian', 'delanguage+norwegian+norwegian-depluralize', 'core+web+custom')
     end

     it "Stress test: language.main=farsi others=misc should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-stress-test', 'delanguage+portuguese+depluralize', 'core+web+farsi+portuguese+farsi')
     end

     it "language.main=arabic should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-arabic', 'delanguage+arabic+depluralize', 'core+web+arabic+custom')
    end

     it "language.main=danish should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-danish', 'delanguage+danish+depluralize', 'core+web+danish+custom')
     end

     it "language.main=dutch should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-dutch', 'delanguage+dutch+depluralize', 'core+web+dutch+custom')
     end

     it "language.main=finnish should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-finnish', 'delanguage+finnish+depluralize', 'core+web+custom')
     end

     it "language.main=french should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-french', 'delanguage+french+depluralize', 'core+web+french+custom')
    end

    it "language.main=german should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-german', 'delanguage+german+depluralize', 'core+web+german+custom')
    end

    it "language.main=hebrew should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-hebrew', 'delanguage+hebrew+depluralize', 'core+web+hebrew+custom')
    end

    it "language.main=italian should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-italian', 'delanguage+italian+depluralize', 'core+web+italian+custom')
    end

    it "language.main=korean should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-korean', 'delanguage+korean+depluralize', 'core+web+korean+custom')
    end

    it "language.main=polish other=russian should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-polish', 'delanguage+russian+depluralize', 'core+web+russian+polish+custom')
    end

    it "language.main=portuguese should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-portuguese', 'delanguage+portuguese+depluralize', 'core+web+portuguese+custom')
    end

    it "language.main=russian should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-russian', 'delanguage+russian+depluralize', 'core+web+russian+custom')
    end

    it "language.main=swedish should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-swedish', 'delanguage+swedish+depluralize', 'core+web+swedish+custom')
    end

    it "language.main=turkish should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-turkish', 'delanguage+turkish+depluralize', 'core+web+custom')
    end

  #!!! need to update lang code to include a korean segmenter!!! is the korean stemmer deprecated?
    it "language.main=korean other: some langs should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-korean-others', 'delanguage+korean+arabic+danish+dutch+finnish+french+german+hebrew+italian+norwegian+portuguese+swedish+turkish+depluralize', 'core+web+arabic+danish+dutch+farsi+french+german+hebrew+italian+polish+portuguese+swedish+korean+custom')
    end

    it "language.main=japanese, other:korean should instantiate to" do
      confirm_segmenter_stem_and_stoplist_value('exqa-lang-vars-japanese-korean', 'japanese', 'delanguage+korean+depluralize',  'core+web+korean+japanese-letters+japanese+custom')
    end
	
    it "language.main=custom, stem:spanish-depluralize stoplist:catalan should instantiate to" do
       confirm_stem_and_stoplist_value('exqa-lang-vars-custom', 'spanish-depluralize', 'catalan')
       end
  end
end
