#!/usr/bin/python

from lxml import etree
import os
import sys
import urllib
import urllib2


TARGET = {'linux':'gronk',
          'solaris':'gronk',
          'windows':'gronk.exe'}

GRONK_URL = '%s://%s:%s/%s/cgi-bin/%s' % (
    'http',
    os.getenv('VIVHOST', 'localhost'),
    os.getenv('VIVHTTPPORT', '80'),
    os.getenv('VIVVIRTUALDIR', 'vivisimo'),
    TARGET[os.getenv('VIVTARGETOS', 'linux')])


def call(action=None, **request_params):
    """Simple call to 'gronk' with plain text return."""
    params = request_params.copy()
    if action:
        params['action'] = action
    data = urllib.urlencode(params)
    return urllib2.urlopen(GRONK_URL + '?' + data).read()


def xml_call(action=None, **request_params):
    """Generic call to 'gronk' with parsed XML return."""
    text = call(action, **request_params)
    xml = etree.fromstring(text)
    return xml


def get_pid_list(service, collection=None):
    """Return a simple Python list of PIDs (strings) for a service."""
    params = {'service':service}
    if collection:
        params['collection'] = collection
    xml = xml_call('get-pid-list', **params)
    assert xml.xpath('OUTCOME')[0].text == 'Success', text
    return [pid.text for pid in xml.xpath('PIDLIST/PID')]


def kill_all_services():
    """Kill all service processes, except for the query-service."""
    # Note that this essentially always reports <OUTCOME>Failure</OUTCOME>
    xml = xml_call('kill-all-services')


if __name__ == "__main__":
    print etree.tostring(xml_call(
            sys.argv[1],
            **dict((arg.split('=', 1) for arg in sys.argv[2:]))))
