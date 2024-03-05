module Velocity
  class QueryService
    def initialize(vapi)
      @vapi = vapi
    end

    def status()
      @vapi.search_service_status_xml.xpath("//service-status/@started").to_s
    end

    def start()
      @vapi.search_service_start
      status
    end
  end
end