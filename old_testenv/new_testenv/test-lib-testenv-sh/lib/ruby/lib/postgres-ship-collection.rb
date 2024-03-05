require 'ship-collection'

class PostgresShipCollection < ShipCollection
  def initialize(vapi, collection, database = "WWII_Navy", table = "vessel_view")
    super(vapi, collection)

    delete
    create("default")

    add_crawl_seed("vse-crawler-seed-database-key",
                   {:server          => "testbed5-1.bigdatalab.ibm.com",
                    :port            => 5432,
                    :username        => "gaw",
                    :password        => "{vcrypt}TMWiymi8UsQ9QvtqWkxuhw==",
                    :database_system => "postgresql",
                    :database        => database,
                    :table           => table})
  end
end
