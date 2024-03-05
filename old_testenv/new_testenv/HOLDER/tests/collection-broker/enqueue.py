#!/usr/bin/python

"""Trivial enqueue to a set of collections.

This is called as a subprocess, often several in parallel, by a test driver."""

import helpers as cb
import sys
import velocityAPI

################################################################
# Go do it...
if __name__ == "__main__":
    print sys.argv[1:], 'begin ...'
    vapi = velocityAPI.VelocityAPI()
    base_name   = sys.argv[1]
    range_start = sys.argv[2]
    range_stop  = sys.argv[3]
    for n in range(int(range_start), int(range_stop)):
        name = (base_name % n)
        url = 'nowhere://' + name
        text = name + '\nThere are many twisty passages, all alike.'
        cb.do_enqueue(vapi, name, url, text)

    print sys.argv[1:], 'all done.'
