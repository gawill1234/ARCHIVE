#!/usr/bin/python

from lxml import etree
import sys
import velocityAPI


def add_test_api(vapi, name):
    """Create a public API function for an internal function.
    The created function name will be based un the underlying function
    with 'test-' added to the beginning."""

    new_name = 'test-' + name
    try:
        resp = vapi.repository_get_md5(element='function', name=new_name)
        return                  # It's already there, just leave it be.
    except velocityAPI.VelocityAPIexception:
        exception, text = sys.exc_info()[1]

    # Grab the formal argument list from the underlying API function
    resp = vapi.repository_get_md5(element='function', name=name)
    prototype = resp.xpath('repository-node/function/prototype')[0]

    # Prepare the new, public, API function
    new_function = etree.Element('function', **{'name':new_name,
                                                'type':'public-api'})
    # Same argument list
    new_function.append(prototype)

    # Copy each argument through
    call_function = etree.SubElement(new_function, 'call-function', name=name)
    for arg in prototype.xpath('declare/@name'):
        w = etree.SubElement(call_function, 'with', **{'name':arg,
                                                       'copy-of':arg})
    # Create the new API function
    resp = vapi.repository_add(node=etree.tostring(new_function))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print 'usage: %s internal-api-function-name'
        print
        print 'Create a public "test-" API function based on an internal API.'
        sys.exit(1)
    vapi = velocityAPI.VelocityAPI()
    add_test_api(vapi, sys.argv[1])
