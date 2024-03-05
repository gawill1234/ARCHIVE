#!/usr/bin/python

import time
import velocityAPI

print "Make sure that our testing 'velocityAPI' package renews login tickets."

total_hours=30                  # more than a day...
interval_minutes=10

vapi = velocityAPI.VelocityAPI(get_ticket=True)

# Take a minor admin action every so often for a long time.
for tick in range(60*total_hours/interval_minutes):
    time.sleep(60*interval_minutes)
    vapi.search_collection_status(collection='default')

print 'Test passed.'
