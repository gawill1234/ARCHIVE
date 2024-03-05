require 'velocity/collection'
require 'velocity/api'
include Velocity

def csol_test_setup()
   vlog "CSOL test setup: create dictionary, ccs and csol collections"
   dc = Collection.new(@vapi, 'example-metadata')
   dc.clean_crawl

   vlog "Creating example-md dictionary"
   page.open "#{@admin}?"
   if page.is_element_present("//div[@class='user']")
     vlog "user already logged in\n"
   else
     page.type "username", "test-all"
     page.type "password", "P@$$word#1?"
     page.click "//input[@value='Log in']"
     page.wait_for_page_to_load "30000"
   end
   page.click "//a[@href='#{@admin}?id=sources.xml.dict&project=query-meta&']/img"
   page.wait_for_page_to_load "50000"
   sleep 3
   if page.is_element_present("//div[@id='nodes-table']//a[@href='?id=sources.xml.longlist&action=jump&lookup=dictionary%20example-md&project=query-meta']")
     vlog "Dictionary already exists, jumping to next test."
   else
     # no api function to configure a dictionary, doing it via admin tool
     # could also do it using repository-get/set (do it later, if enough time)
     vlog "Creating Dictionary. This will take a few seconds..."
     page.click "//a[@href='#{@admin}?id=dict.create&project=query-meta&']/img"
     page.wait_for_page_to_load "30000"
     page.type "e-v", "example-md"
     page.select "nvp-select-default", "label=base"
     page.click "SUBMIT"
     page.wait_for_page_to_load "30000"
     page.click "link=Inputs"
     page.wait_for_page_to_load "30000"
     page.click "//td[@id='work-panel']//a[.='Add Input Source']"
     page.select "//select", "label=Search Collection"
     page.click "//span[.='Add']"
     page.wait_for_page_to_load "30000"
     page.type "//input[@id='id-admin-1']", "example-metadata"
     page.click "SUBMIT"
     page.wait_for_page_to_load "30000"
     page.click "link=Overview"
     page.wait_for_page_to_load "30000"
     page.click "link=build"
     sleep 10
     status = page.get_text("//td[@class='a_header']")
   end

   vlog "\nCreating a ccs-collection\n******"
   ccs = Collection.new(@vapi, 'ccs-collection-example-md')
   ccs.create('ccs-collection-default')
   status = ccs.crawler_status
   if status.include?("none")
     ccs.add_ccs_collection_seeds('example-metadata', 'example-md')
     vlog "starting crawl... "
     ccs.start_crawl
   elsif status.include?("stopped")
     vlog "ccs-collection-example-md already exists and has been crawled, moving to next test"
   elsif status.include?("running")
     vlog "ccs-collection-example-md crawl in progress, this should never happen"
   end

   vlog "\nCreating a csol\n******"
   csol = Collection.new(@vapi, 'csol-example-md')
   csol.create('cs-ontolection-default')
   status = csol.crawler_status
   if status.include?("none")
     csol.add_csol_collection_seed('ccs-collection-example-md')
     vlog "starting crawl... "
     csol.start_crawl
   elsif status.include?("stopped")
     vlog "csol-example-md already exists, moving to next test"
   elsif status.include?("running")
     vlog "csol-example-md crawl in progress, this should never happen"
   end
end

def clean_up()
  vlog "Verifying that ccs and csol collections were deleted"
  ccs = Collection.new(@vapi, 'ccs-collection-example-md')
  vlog "Deleting ccs-collection-example-md"
  ccs.delete
  csol = Collection.new(@vapi, 'csol-example-md')
  vlog "Deleting csol-example-md"
  csol.delete
end