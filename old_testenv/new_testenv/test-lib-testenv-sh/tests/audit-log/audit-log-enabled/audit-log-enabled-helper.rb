require 'collection'
require 'vapi'

def setup
  msg "Setup"
  @test_results.associate(@collection)
  @collection.delete
  @collection.create
  velocity = TESTENV.velocity
  user = TESTENV.user
  password = TESTENV.password
  @vapi = Vapi.new(velocity, user, password)
end

def disable_audit_log
  @collection.set_crawl_options({ :audit_log   => "none"}, [])
end

def enable_audit_log
  @collection.set_crawl_options({ :audit_log   => "all"}, [])
end

def enqueue_generated_exception(node)
  audit_log_disabled_exception = false
  begin
    @result = @vapi.search_collection_enqueue_xml(
                                     :collection => TESTENV.test_name,
                                     :subcollection => "live",
                                     :crawl_nodes => node)
  rescue Exception => ex
    if ex.message.slice("The enqueue request contains a node with the originator attribute, but the audit log is disabled.")
       audit_log_disabled_exception = true
    end
  ensure
  end
  audit_log_disabled_exception
end

# test data
CRAWL_URL = <<-HERE
<crawl-url enqueue-type="reenqueued"
           status="complete"
           synchronization="indexed-no-sync"
           url="dummy"
           originator="test"
           >
  <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
    <document>Hello world</document>
  </crawl-data>
</crawl-url>
HERE

CRAWL_URLS_CRAWL_URL = <<-HERE
<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="dummy"
             originator="test"
             >
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>Hello world</document>
    </crawl-data>
  </crawl-url>
</crawl-urls>
HERE

CRAWL_URLS = <<-HERE
<crawl-urls originator="test">
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="dummy"
             >
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>Hello world</document>
    </crawl-data>
  </crawl-url>
</crawl-urls>
HERE

CRAWL_DELETE = <<-HERE
<crawl-delete originator="test" url="dummy" synchronization="indexed-no-sync" />
HERE

CRAWL_URLS_CRAWL_DELETE = <<-HERE
<crawl-urls>
  <crawl-delete enqueue-type="reenqueued"
                synchronization="indexed-no-sync"
                url="dummy"
                originator="test"
             />
</crawl-urls>
HERE

CRAWL_URLS_INDEX_ATOMIC = <<-HERE
<crawl-urls>
  <index-atomic originator="test">
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="dummy"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document>Hello world</document>
      </crawl-data>
    </crawl-url>
  </index-atomic>
</crawl-urls>
HERE

INDEX_ATOMIC = <<-HERE
<index-atomic originator="test">
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="dummy"
             >
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>Hello world</document>
    </crawl-data>
  </crawl-url>
</index-atomic>
HERE

INDEX_ATOMIC_CRAWL_URL = <<-HERE
<index-atomic>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="dummy"
             originator="test"
             >
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>Hello world</document>
    </crawl-data>
  </crawl-url>
</index-atomic>
HERE

INDEX_ATOMIC_CRAWL_DELETE = <<-HERE
<index-atomic originator="test">
  <crawl-delete enqueue-type="reenqueued"
                synchronization="indexed-no-sync"
                url="dummy"
                originator="test"
             />
</index-atomic>
HERE

CRAWL_URL_WITHOUT_ORIGINATOR = <<-HERE
<crawl-url enqueue-type="reenqueued"
           status="complete"
           synchronization="indexed-no-sync"
           url="dummy"
           >
  <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
    <document>Hello world</document>
  </crawl-data>
</crawl-url>
HERE
