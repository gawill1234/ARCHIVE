require 'test_helper' 

def stemming_qe_test_setup()
  vlog "Stemming of expanded query: starting setup"
  project_xml = Nokogiri::XML <<HERE
            <options name="exqa-qe-stemming" load-options="core" modified-by="font" max-elt-id="4" modified="1258748801">
               <load-options name="core" />
               <set-var name="query-expansion.enabled">true</set-var>
               <set-var name="query-expansion.stem-expansions">true</set-var>
               <set-var name="query-expansion.ontolections">ontolection-english-spelling-variations ontolection-english-general-basic-example</set-var>
               <set-var name="query-expansion.suggestion-symmetric">translation|spanish</set-var>
            </options>
HERE
  begin
    vlog "Deleting pre-existing exqa-qe-stemming project, if any"
    @vapi.repository_delete({:element => "options", :name => 'exqa-qe-stemming'})
  rescue
  end
  begin
    vlog "Adding exqa-qe-stemming project to the repository"
    @vapi.repository_add({:node => project_xml.root})
  rescue
  end
 
  prepare_crawl('ontolection-english-spelling-variations')
  prepare_crawl('ontolection-english-general-basic-example')
  prepare_crawl('ontolection-english-general-advanced-example')

end
