import pycurl
import StringIO
from lxml import etree
import lxml.html
import urllib
import urllib2
import cookielib
import os
import fileinput
# FIXME: Handle errors??

# These are only used by the main method
default_user="testuser"
default_password="Baseball123"
default_target_url="https://telligent-dev/vivisimo/cgi-bin/admin.exe"

USER_AGENT = "Mozilla/4.05 [en] (X11; U; Linux 4.0.32 i586)"

#initial try to get resource: follow expected redirection and return html form with security token
def get_security_token_for_url(target_url, username, password):
	crl = pycurl.Curl()
	crl.setopt(pycurl.URL, target_url)
	crl.setopt(pycurl.USERAGENT, USER_AGENT)
        crl.setopt(pycurl.USERPWD, "%s:%s" % (username, password))
	crl.setopt(pycurl.HTTPAUTH, pycurl.HTTPAUTH_NTLM)
	crl.setopt(pycurl.FOLLOWLOCATION, 1)
	crl.setopt(pycurl.UNRESTRICTED_AUTH, 1)
	crl.setopt(pycurl.SSL_VERIFYPEER, 0)

	out = StringIO.StringIO()
	crl.setopt(pycurl.WRITEFUNCTION, out.write)

	crl.perform()
	crl.close()

	response = out.getvalue()
	return response

def extract_form_action_url(tree):
        return tree.xpath("//form/@action")[0]

def extract_form_input_element(tree, elemName):
	return urllib.quote_plus(tree.xpath("//form/input[@name='" + elemName + "']/@value")[0])

def build_post_data(tree):
	wa_param=extract_form_input_element(tree, 'wa')
	wctx_param=extract_form_input_element(tree, 'wctx')
	wresult_param=extract_form_input_element(tree, 'wresult')
	post_data="wa=%s&wctx=%s&wresult=%s" % (wa_param, wctx_param, wresult_param)
	return post_data

#parse and submit form to get security cookie
def redeem_security_token_for_cookie(tokenForm, urlOpener):
	tree = lxml.html.fromstring(tokenForm)
	actionUrl = extract_form_action_url(tree)
	postData = build_post_data(tree)

	response = urlOpener.open(actionUrl, postData);

def init_for_cba(urlOpener, target_url, user, password):
	urlOpener.addheaders = [('User-agent', USER_AGENT)]
        print "Getting new CBA Auth cookie"
        tokenForm = get_security_token_for_url(target_url, user, password)
        redeem_security_token_for_cookie(tokenForm, urlOpener)
	return urlOpener

def format_cookie_for_header(cookie):
  return "%s=%s" % (cookie.name, cookie.value)

def fetch_cba_auth_cookie(target_url, user, password):
       cookieProcessor = urllib2.HTTPCookieProcessor()
       urlOpener = urllib2.build_opener(cookieProcessor)
       init_for_cba(urlOpener, target_url, user, password)

       # extract the FedAuth cookie
       cookieJar = cookieProcessor.cookiejar

       authCookies = ""

       for cookie in cookieJar:
         # There may be more than one FedAuth cookie. We need to pass all of them
         if cookie.name.startswith("FedAuth"):
           if len(authCookies) > 0:
             authCookies = authCookies + ";"

           authCookies = authCookies + format_cookie_for_header(cookie)

       return authCookies

if __name__ == "__main__":
        print fetch_cba_auth_cookie(default_target_url, default_user, default_password)
