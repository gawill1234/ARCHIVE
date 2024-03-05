def enqueue_vse_key_nodes
  crawl_nodes = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy"
               forced-vse-key="fvk"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">Crawl-url forced vse-key</content>
        </document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy2"
               forced-vse-key="fvk"
               forced-vse-key-normalized="forced-vse-key-normalized"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">Crawl-url forced vse-key normalized</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy3"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document vse-key="dvk"
                  ><content name="description">Document vse-key</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy4"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document vse-key="dvk"
                  vse-key-normalized="vse-key-normalized"
                  ><content name="description">Document vse-key normalized</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy5"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document key="dk"
                  ><content name="description">Document key</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy6a"
               >
      <crawl-data content-type="application/vxml" encoding="xml">
        <document vse-key="dkn"
                  vse-key-normalized="vse-key-normalized"
                  ><content name="description">Document key normalized - Pre-normalized document with key to dup</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy6b"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document key="dkn"
                  vse-key-normalized="vse-key-normalized"
                  ><content name="description">Document key normalized</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy7"
               >
      <crawl-data content-type="application/vxml-unnormalized"
                  encoding="xml"
                  vse-key="cdvk"
                  >
        <document><content name="description">Crawl-data vse-key</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy8"
               >
      <crawl-data content-type="application/vxml-unnormalized"
                  encoding="xml"
                  vse-key="cdvk"
                  vse-key-normalized="vse-key-normalized"
                  >
        <document><content name="description">Crawl-data vse-key normalized</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy9"
               vse-key="cvk"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">Crawl-url vse-key</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy10"
               vse-key="cvk"
               vse-key-normalized="forced-vse-key-normalized"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">Crawl-url vse-key normalized</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy11"
               >
      <crawl-data anchor="http://vivisimo.com/dummy11#anchor" content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">Crawl-url anchor</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy12"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <vce>
          <document url="http://vivisimo.com/notdummy"><content name="description">Document url</content></document>
          <document url="http://vivisimo.com/notdummy2"><content name="description">Second document url</content></document>
        </vce>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy13"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">Crawl-url url</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy14"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <vce>
          <document><content name="description">Multiple document enqueue</content></document>
          <document><content name="description">Multiple document enqueue, second document</content></document>
          <document><content name="description">Multiple document enqueue, third document</content></document>
        </vce>
      </crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE

  @collection.enqueue_xml(crawl_nodes)
end
