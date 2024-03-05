require File.dirname(__FILE__) + '/../helpers/spec_helper'
require 'annotations_two_installations_helper'


second_install_velocity_url = ''
second_install_host = ''
second_install_port = ''
second_install_username = ''
second_install_password = ''

=begin example:
second_install_velocity_url = 'http://nichols-7.5.dev3.vivisimo.com/vivisimo/cgi-bin/velocity'
second_install_host = 'dev3.vivisimo.com'
second_install_port = '7778'
second_install_username = 'nichols'
second_install_password = '0qyr.MTO'
=end

data_collection = 'rspec-vivi-site-two'
data_source = data_collection + '-front'
ics_collection = 'rspec-vivi-site-two-ics-collection'
ics_source = ics_collection + '-front'
project = 'rspec-vivi-site-two'
display = 'rspec-vivis-site-two-display'

vapi_second_install = Velocity::API.new(second_install_velocity_url,
                                         second_install_username,
                                         second_install_password)


if !second_install_velocity_url.eql?('') && !second_install_username.eql?('') && !second_install_password.eql?('')
  describe "second installation set up" do
    before(:all) do
      annotations_two_installations_setup_frontend(@vapi, data_source, ics_source, 
                                                   project, display, second_install_velocity_url, 
                                                   second_install_username, second_install_password, 
                                                   data_collection, ics_collection, 
                                                   second_install_host, second_install_port)
      annotations_two_installations_setup_backend(vapi_second_install, data_collection, ics_collection,
                                                   project, display)
      start_new_browser_session
      admin_login
    end


    it "should be able to get results from the backend through the frontend" do
      @qm.query_vxml('v:project' => project, :query => 'search')
      @qm.vxml.xpath("/vce/list/document").should_not be_empty
      @qm.vxml.xpath("/vce//added-source[@name='#{data_source}']/parse").attr("url").value.should match(/#{second_install_host}/)
      @qm.vxml.xpath("/vce//added-source[@name='#{ics_source}']/parse").attr("url").value.should match(/#{second_install_host}/)
    end

    it "should be able to tag the results" do
      page.open "#{@query_meta}?v:sources=#{data_source}&v:project=#{project}&"
      page.wait_for_page_to_load(10000)
      page.click("//span[@id='text-Ndoc0-tags']/a")
      page.type("id=vivtag-Ndoc0-field", "thanksgibbons")
      page.click("//form[@id='wrapper-Ndoc0-tags']/span[@class='button'][1]")
      sleep 15
      page.get_text("//div[@id='view-Ndoc0-tags']/a[@class='usertag tagvalue readonly']").should match(/thanksgibbons/)
    end




    it "should be able to use folders and saved queries when the empty query is not allowed" do
      pending "additional setup" do
        false.should be_true
      end
    end
  end
else
  describe "Second installation not set up" do
    it "should have a second install available" do
      pending "you need to set the variables at the top of annotation_two_installations_spec.rb to point to a second install in order for these tests to run." do
        false.should be_true
      end
    end
  end
end