#!/usr/bin/env ruby

require 'misc'
require 'collection'
require 'velocity/collection/restore'

collection = Collection.restore_saved_collection('danone-1',
    '/testenv/saved-collections/danone/danone-1-tmp')

msg 'Collection restoration complete.'

exec './qs-operator.py'
