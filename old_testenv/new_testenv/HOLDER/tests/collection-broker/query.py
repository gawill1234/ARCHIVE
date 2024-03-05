#!/usr/bin/python

"""Trivial enqueue to a set of collections.

This is called as a subprocess, often several in parallel, by a test driver."""

import helpers as cb
import sys
import time
import velocityAPI

no_progress_limit=60*60

################################################################
# Go do it...
if __name__ == "__main__":
    print sys.argv[1:], 'begin ...'
    vapi = velocityAPI.VelocityAPI()
    base_name   = sys.argv[1]
    range_start = sys.argv[2]
    range_stop  = sys.argv[3]
    working_list = [base_name % n
                    for n in range(int(range_start), int(range_stop))]
    last_found_time = time.time()
    while working_list:
        found = []
        for name in cb.shuffle(working_list):
            if cb.do_single_search(vapi,
                                   name,
                                   ['There are many twisty passages,'
                                    ' all alike.',
                                    'url="nowhere://' + name]):
                found.append(name)
                working_list.remove(name)
        if found:
            print time.ctime(), 'found\t' + '\n\t\t\t\t'.join(found)
            last_found_time = time.time()
        else:
            if len(working_list) < 10:
                print time.ctime(), 'nothing found, need:', working_list
            else:
                print time.ctime(), 'nothing found,', \
                    len(working_list), 'remaining.'
            assert time.time() - last_found_time < no_progress_limit, \
                'Too much time has passed since new results found.'
            vapi.search_service_start() # Sometimes we kill it off...

    print sys.argv[1:], 'all done.'
