#!/usr/bin/python

import sys
import threaded_work
import time

def good_worker(i):
    print 'good_worker says:', i

def bad_worker(i):
    print i/0

def launcher():
    print 'in Launcher'
    for i in xrange(5):
        threaded_work.worker(good_worker, [i])
    for i in xrange(5):
        threaded_work.worker(bad_worker, [i])


def main():
    print 'starting main()'
    retval =  threaded_work.top(launcher).get()
    print 'retval =', retval
    if retval:
        time.sleep(2)
        pass
    print 'retval =', retval
    return retval

if __name__ == "__main__":
    threaded_work.allow_control_c()
    sys.exit(main())

