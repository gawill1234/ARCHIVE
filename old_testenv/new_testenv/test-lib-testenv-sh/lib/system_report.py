#!/usr/bin/python

import os
import sys
import time
from datetime import datetime
import velocityAPI
from lxml import etree

ATTRIBUTES = ['date', 'type', 'level', 'id', 'message']
TYPES = ['error', 'warning', 'msg']
LEVELS = ['errors-high', 'errors-low']

# Unknown type is worse than any known.
# Unknown error level is worse than any known.
# In order from most to least severe.
SEVERITY = dict(((label, value) for value, label
                 in enumerate(['type-unknown',
                               'error-unknown',
                               'error-high',
                               'error-low',
                               'warning',
                               'msg'])))

CHUNK_SIZE=10000


def severity(item):
    if item.get('type') not in TYPES:
        return SEVERITY['type-unknown']
    if item['type'] == 'error':
        if item.get('level') not in LEVELS:
            return SEVERITY['error-unknown']
        if item['level'] == 'errors-high':
            return SEVERITY['error-high']
        if item['level'] == 'errors-low':
            return SEVERITY['error-low']
    return SEVERITY[item['type']]


def cook(system_report):
    return [item.attrib for item in system_report.xpath('system-report-item')]


def full_report(start, end):
    """This returns a Python list, in descending date/time order.
    Each list item is a Python dict that contain the attributes of a
    single system-report-item.

    The input start and end times must be ISO 8601 formatted strings,
    for example 2009-11-21T16:47:09-05:00"""
    vapi = velocityAPI.VelocityAPI()

    items = []
    need_more = True
    while need_more:
        sr = vapi.reports_system_reporting(start=start,
                                           end=end,
                                           max_items=CHUNK_SIZE)
        new_items = cook(sr)
        items += new_items
        if len(new_items) < CHUNK_SIZE:
            need_more = False
        else:
            # Make sure we didn't blow out our limits
            assert items[0]['date'] != items[-1]['date'], \
                'Exceeded %d system report messages in a single second!' \
                % CHUNK_SIZE

            # We assume that the most recent message is first and
            # oldest message is last.

            # We can't be sure we got all of the items for the oldest
            # date/time. So, throw away what we did get for that
            # second and make our next request end on that second.
            end = items[-1]['date']
            while items[-1]['date'] == end:
                del items[-1]
    return items


def main(start, end, print_severity='warning', fail_severity='error-high'):
    retval = 0
    if SEVERITY[print_severity] < SEVERITY[fail_severity]:
        print 'Adjusting fail_severity to match print_severity.'
        fail_severity = print_severity

    for item in full_report(start, end):
        if severity(item) <= SEVERITY[fail_severity]:
            retval = 1
        if severity(item) <= SEVERITY[print_severity]:
            print '%-26s %-8s %-13s %s  %s' % (item['date'].replace('T', ' '),
                                               item.get('type'),
                                               item.get('level'),
                                               item.get('id'),
                                               item.get('message'))
    return retval


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print 'usage:', sys.argv[0],\
            'start_date_time end_date_time [print_severity] [fail_severity]'
        sys.exit(2)
    sys.exit(main(*sys.argv[1:]))
