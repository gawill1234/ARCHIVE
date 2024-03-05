require 'ship-collection'

class OracleShipCollection < ShipCollection
  def initialize(vapi, collection)
    super(vapi, collection)

    delete
    create("default")

    add_crawl_seed("vse-crawler-seed-database-key",
                   {:server          => "testbed6-4.bigdatalab.ibm.com",
                    :port            => 1521,
                    :username        => "gaw",
                    :password        => "{vcrypt}TMWiymi8UsQ9QvtqWkxuhw==",
                    :database_system => "oracle",
                    :database        => "orcl",
                    :table           => "vessel_view"})
  end
end
