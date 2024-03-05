#!/usr/bin/python

import os
import sys
import time
import threading
import urllib
import urllib2
import cba_auth
from lxml import etree


class VelocityAPIempty(Exception):
    """This exception describes a specific issue: The response to a
    Velocity API call was completely blank."""
    pass

class VelocityAPIexception(Exception):
    """By convention, the first item in 'args' is the parsed
    lxml.etree.Element of the exception and the second item is the
    original text returned by the Velocity API call."""
    def __str__(self):
        """Make sure that printing the exception gives useful output."""
        try:
            return self.args[1]
        except:
            return str(self.args)


class VelocityAPI:
    """Helper for doing Velocity API calls.

    Implemented as a class so that we can handle arbitrary function
    names and defaults (such as target host and user) stick.

    Defaults can be passed into the constructor. If they are not passed
    in, we look for environment variables: VIVHOST, VIVHTTPPORT,
    VIVVIRTUALDIR, VIVUSER, VIVPW, and VIVTARGETOS.

    All Velocity API calls are supported. Note that underscores in
    Python names are translated into dashes in Velocity API names.

    An example:

    vapi = VelocityAPI()
    xml = vapi.search_service_start()
    xml = vapi.search_collection_create(collection='Test Search Collection')"""

    def __init__(self,
                 protocol='http',
                 host_port=None,
                 context_root=None,
                 username=None,
                 password=None,
                 get_ticket=False,
                 use_cba=False,
                 return_element_tree=True):
        """Fill in defaults and open our timings output file."""
        # Connection stuff can be passed in above, or be pulled from
        # the environment, otherwise use hardwired defaults

        if not host_port:
            host_port = os.getenv('VIVHOST', 'localhost') \
                + ':' + os.getenv('VIVHTTPPORT', '80')
        if not context_root:
            context_root = os.getenv('VIVVIRTUALDIR', 'vivisimo')
        if not username:
            username = os.getenv('VIVUSER', 'test-all')
            # Only auto-fill the password when we did so for the username.
            if not password:
                password = os.getenv('VIVPW', 'P@$$word#1?')

        subdir = os.getenv('VIVASPXDIR', 'cgi-bin')
        self.__cgi_bin = protocol + '://' + host_port \
            + '/' + context_root + '/' + subdir + '/'

        if ( subdir != 'cgi-bin' ):
           self.__base_url = self.__cgi_bin + 'velocity.aspx'
        else:
           if os.getenv('VIVTARGETOS') == 'windows':
              self.__base_url = self.__cgi_bin + 'velocity.exe'
           else:
              self.__base_url = self.__cgi_bin + 'velocity'

        self.__base_params = {'v.app':'api-rest'}
        self.__ticket_expire = None
        # Always setup to handle cookies.
        self.__url = urllib2.build_opener(urllib2.HTTPCookieProcessor)

        if use_cba:
	   self.__url = cba_auth.init_for_cba(self.__url, self.__base_url, username, password)

        if get_ticket:
	    self.get_ticket(username, password)

        if not(use_cba or get_ticket):
            try:
                # Turn on HTTP keep alives, if we can find the library
                # Not sure the cookie part works here...
                import urlgrabber.keepalive
                self.__url = urllib2.build_opener(
                    urlgrabber.keepalive.HTTPHandler,
                    urllib2.HTTPCookieProcessor)

            except ImportError:
                pass

            if username:
                self.__base_params['v.username'] = username
                # Only set a password if we have a username.
                if password:
                    self.__base_params['v.password'] = password

        # Tell the server we want XML returned to us.
        self.__url.addheaders += [('Accept', 'text/xml')]
        self.__return_et = return_element_tree

        self.__files_setup(host_port)

        return


    def __files_setup(self, host_port):

        unique_name = host_port.split('.')[0].split(':')[0] \
            + '-' + str(os.getpid())  \
            + '-' + threading.currentThread().getName()
        try:
            os.mkdir('querywork')       # Try to create the logging directory.
        except OSError:                 # Don't worry about failure.
            pass                        # (It's probably already there.)

        self.__timing_setup(unique_name)
        self.__detail_setup(unique_name)

        return


    def __detail_setup(self, unique_name):

        # Allow suppressing detail logging (default to turned on).
        if os.getenv('VIVNODETAIL') == 'true':
            self.__detail = None
        else:
            self.__detail = open('querywork/vapi-detail-%s.tsv' % unique_name,
                                 'a')

        return


    def __timing_setup(self, unique_name):
        #
        #   Three possible values:
        #      false = do timing the old way
        #      true =  output elapsed time instead of start and stop
        #      off =  disable all timing
        #
        #   Defaults to the old way of doing things.
        #
        do_ts = os.getenv('VIVDOELAPSED', 'false')

        if ( do_ts == 'true' ):
           self.__doelapsed = 1
        elif ( do_ts == 'off' ):
           self.__doelapsed = 2
        else:
           self.__doelapsed = 0

        if ( self.__doelapsed != 2 ):
           self.__sequence_num = 1
           self.__timings = open('querywork/vapi-timings-%s.tsv' % unique_name,
                                 'a')
           if ( self.__doelapsed == 0 ):
              self.__timings.write('%s\t%s\t%s\n' % ('# -- start time --',
                                                     '---- end time ----',
                                                     'v.function'))
           else:
              self.__timings.write('%s\t%s\t%s\n' % ('# -- sequence num --',
                                                 '---- elapsed time --',
                                                 'v.function'))

        return


    def __renew_ticket(self):
        response = self.__url.open(self.__ticket_url)
        data = response.read()
        assert ' You are now logged in ' in data, data
        self.__ticket_expire = time.time() + 59*60 # just under an hour


    def get_ticket(self, username, password):
        """Login to Velocity admin to get authentication cookies."""
        params = {'id': 'login.logged',
                  'username': username,
                  'password': password}
        if os.getenv('VIVTARGETOS') == 'windows':
            admin_url = self.__cgi_bin + 'admin.exe'
        else:
            admin_url = self.__cgi_bin + 'admin'
        self.__ticket_url = admin_url + '?' + urllib.urlencode(params)
        self.__renew_ticket()


    def __twiddle_name(self, name):
        """Map Python name to a Velocity API name.

        Velocity API parameter names include characters that are not legal
        Python identifiers.  We use '__' for a period and '_' for a dash."""

        return name.replace('__', '.').replace('_', '-')


    def clean_for_tsv(self, raw):
        """Return a cleaned up string for use as a single column in a
        tab separated file.

        New line (also known as line feed), Carriage Return and Tab
        each get replaced with 'C' style backslash escape sequence."""
        return raw.replace('\n','\\n').replace('\r','\\r').replace('\t','\\t')


    def time_a_vapi(self, post_data):
        error = None
        t1 = time.time()
        if self.__detail is not None:
            self.__detail.write('%s\t%s?%s\t%f\t'
                                % ('POST',
                                   self.__base_url,
                                   post_data,
                                   t1))
            self.__detail.flush()

        try:
           response = self.__url.open(self.__base_url, post_data)
           # Give my caller a way to get to the HTTP headers, etc.
           self.data = response.read()
           self.info = response.info()
           #### self.getcode = response.getcode()  # Only in newer Python...
           self.geturl = response.geturl()
        except urllib2.URLError:
           error = sys.exc_info()

        t2 = time.time()
        return t1, t2, error


    def output_timing(self, t1, t2, func_name):

        if ( self.__doelapsed != 2 ):
           if ( self.__doelapsed == 0 ):
              self.__timings.write('%f\t%f\t%s\n'
                                   % (t1, t2, func_name))
           else:
              self.__timings.write('%d\t\t\t%f\t\t%s\n'
                                   % (self.__sequence_num, t2 - t1, func_name))
              self.__sequence_num += 1
           self.__timings.flush()

        return


    def call(self, function=None, **request_params):
        """Make a Velocity API call, using REST."""
        # Start with my defaults (which may be overridden).
        params = self.__base_params.copy()
        for key, value in request_params.items():
            if value != None:
                if type(value) == unicode:
                    # Explicitly deal with encoding Unicode strings.
                    params[self.__twiddle_name(key)] = value.encode('utf-8')
                else:
                    params[self.__twiddle_name(key)] = value
        # Use the specified function name, if it's there.
        if function:
            params['v.function'] = function

        post_data = urllib.urlencode(params)

        if self.__ticket_expire and self.__ticket_expire <= time.time():
            self.__renew_ticket()
        tries = 0
        retry = True
        while retry:
            if tries > 0:
                print time.ctime(), 'retrying ...'
            tries += 1

            t1, t2, error = self.time_a_vapi(post_data)
            if not error:
                if self.data != '':
                    retry = False
                else:
                    print '%s %s %s %s%s%s' % (time.ctime(),
                                               'EMPTY',
                                               'POST',
                                               self.__base_url,
                                               '&v.function=',
                                               params.get('v.function'))
                    if self.__detail is not None:
                        self.__detail.write('%f\t%s\t%s\n'
                                            % (time.time(),
                                               'EMPTY',
                                               self.clean_for_tsv(str(self.info))))
                    if tries > 9:
                        retry = False # Only retry a few times...
            else:
                print '%s %s: %s %s %s%s%s' % (time.ctime(),
                                               error[0],
                                               error[1],
                                               'POST',
                                               self.__base_url,
                                               '&v.function=',
                                               params.get('v.function'))
                if self.__detail is not None:
                    self.__detail.write('%f\t%s:\t%s\n'
                                        % (time.time(),
                                           error[0],
                                           error[1]))
                if tries > 9:   # Only retry a few times...
                    raise error[0], error[1], error[2]

        if self.__detail is not None:
            self.__detail.write('%f\t%s\t%s\n'
                                % (t2, 'DATA', self.clean_for_tsv(self.data)))
            self.__detail.flush()

        self.output_timing(t1, t2, params.get('v.function','None'))

        if not self.__return_et:
            return self.data
        if self.data == '':
            raise VelocityAPIempty, \
                'empty string returned by Velocity API call %s' \
                % params.get('v.function','')
        et = etree.fromstring(self.data)
        if et.tag == 'exception':
            if os.getenv('VIVEXCONTINUE') != 'True':
                raise VelocityAPIexception, (et, self.data)
            print '**************************************'
            print '  EXCEPTION ENCOUNTERED'
            print self.data
            print '  CONTINUING BECAUSE VIVEXCONTINUE = True'
            print '**************************************'
        return et


    def __helper(self, **request_params):
        """This is a helper for __getattr__.
        This carries the function name forward."""
        return self.call(self.__function, **request_params)


    def __getattr__(self, name, **request_params):
        """Treat an unknown function name as a Velocity API name."""
        # Hang on the the cleaned up name:
        self.__function = self.__twiddle_name(name)
        # Give the caller a reference to our helper function.
        return self.__helper


    def __del__(self):
        # Try to avoid leaking file handles.
        self.__timings.close()
        if self.__detail is not None:
            self.__detail.close()


if __name__ == "__main__":
    vapi = VelocityAPI(return_element_tree=False) # Don't parse the XML
    print vapi.call(sys.argv[1],
                    **dict((arg.split('=', 1) for arg in sys.argv[2:])))
