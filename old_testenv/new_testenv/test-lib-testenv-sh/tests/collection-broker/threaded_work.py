#!/usr/bin/python

"""Some wrappers for Python threading to assure that a program can
exit quickly in the face of an unhandled exception in any thread."""

import Queue
import signal
import sys
import threading

# This is a process-wide singlton
__control_q = Queue.Queue(16)


def allow_control_c():
    """Allow the user to use Control-C to immediately stop the whole program.

    Note, the calling program needs to call this..."""
    signal.signal(signal.SIGINT, signal.SIG_DFL)


def __wrapper(target, args, kwargs):
    global __control_q
    try:
        return target(*args, **kwargs)
    except:
        __control_q.put(1)  # Tell the main we've failed and
        raise               # spit out the exception.


def worker(target, args=(), kwargs={}):
    """Start a worker thread that participates in the
    exit-on-exception mechanisms setup by top.

    The created and running thread is returned."""

    t = threading.Thread(target=__wrapper, args=(target, args, kwargs))
    t.setDaemon(True)
    t.start()
    return t


def __top_wrapper(target, args, kwargs):
    """Start the top thread."""
    __wrapper(target, args, kwargs)
    __control_q.put(0)


def top(target, args=(), kwargs={}):
    """This is called from the main program, with the main action
    function and an argument list for that function.

    This function returns immediately, with a Queue as the return
    value.  The caller should wait on a "get()" from the Queue. The
    value from the Queue is a Unix-style return code. Zero means
    successful completion, any other value means a failure. More
    specifically, we'll return a one for any unhandled Python
    exception being thrown out of any function running in any thread.

    The main action function can create an arbitrary number of
    additional worker threads, via the worker function (defined
    above)."""

    global __control_q
    t = threading.Thread(target=__top_wrapper, args=(target, args, kwargs))
    t.setDaemon(True)
    t.start()
    return __control_q


if __name__ == "__main__":
    print 'I should do some simple test/example, but not such luck...'
