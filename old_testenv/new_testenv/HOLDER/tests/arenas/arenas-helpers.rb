#!/usr/bin/env ruby

require 'misc'

def configure_arenas(c, enable=false)
  xml = c.xml
  set_option(xml, 'vse-index', 'vse-index-option', 'arenas', enable)
  c.set_xml(xml)
end
