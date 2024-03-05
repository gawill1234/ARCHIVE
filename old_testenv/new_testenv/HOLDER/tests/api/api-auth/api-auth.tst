#!/usr/bin/python

import os
import sys
import velocityAPI
from lxml import etree


def check(test, description, xml):
    if test:
        return
    print 'Test failed:', description
    print etree.tostring(xml, pretty_print=True)
    print 'Test failed:', description
    sys.exit(0)


def main():
    print 'Simple test that authentication is required for REST API calls.'\
        ' See Bug 18197.'

    # This is an odd instantiation of VelocityAPI.
    # By specifying a username, but no password,
    # we avoid having any password auto-filled in.
    vapi = velocityAPI.VelocityAPI(username='nobody')

    username = os.getenv('VIVUSER', 'test-all')
    password = os.getenv('VIVPW', 'P@$$word#1?')

    # First, we pass in both user and valid password. Should succeed.
    # This is just a sanity check that the test itself is good.
    resp = vapi.search_collection_status(collection='default',
                                         v__username=username,
                                         v__password=password)
    check(resp.tag == '__CONTAINER__', 'good login', resp)

    # Just a username and no password should fail with a "core-authenticate-error".
    try:
        resp = vapi.search_collection_status(collection='default',
                                             v__username=username)
        check(False, 'no password', resp)
    except velocityAPI.VelocityAPIexception:
        exception = sys.exc_info()[1][0]
        check(exception.get('id') == 'CORE_AUTHENTICATE', 
              'no password', exception)
        check(exception.get('name') == 'core-authenticate-error', 
              'no password', exception)

    # A username and bad password should fail with a "core-authenticate-error".
    try:
        resp = vapi.search_collection_status(collection='default',
                                             v__username=username,
                                             v__password='incorrect-password')
        check(False, 'bad password', resp)
    except velocityAPI.VelocityAPIexception:
        exception = sys.exc_info()[1][0]
        check(exception.get('id') == 'CORE_AUTHENTICATE', 
              'bad password', exception)
        check(exception.get('name') == 'core-authenticate-error', 
              'bad password', exception)

    print 'Test passed :-)'         # Failures are the 'assert' statements...

if __name__ == "__main__":
    main()
