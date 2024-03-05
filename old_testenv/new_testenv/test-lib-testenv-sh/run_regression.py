#!/usr/bin/python

import os
import signal
import smtplib
import subprocess
import sys
import threading
import time

# needs test list file name and output xml report file name
# VTD = 'exec vtd -T 9997 -i %s -x %s'
# VTD = 'new-vtd %s %s'
VTD = 'vtd2 %s %s'
NEW_RESULTS = '/testenv/NEW_RESULTS'
SLEEP_TIME = 10

# For each potential testing target host, the build target and host description.
TARGET_MAP = {'testbed1':('linux-x86_64',      'linux_64_o'), # old(er)
              'testbed2':('windows-x86_64',    'windows_64_2003'),
              'testbed4':('linux-x86_64',      'linux_64'),
              'testbed6':('linux-x86_64',      'linux_64_s'), # small
              'testbed7':('solaris-sparc',     'solaris_64_s'), # small
              'testbed8':('windows-i386',      'windows_32_2003'),
              'testbed9':('windows-x86_64',    'windows_64_2008'),
              'testbed10':('linux-i386',       'linux_32'),
              'testbed11':('windows-i386',     'windows_32_2008'),
              'testbed12':('solaris-sparc',    'solaris_64'),
              'testbed14':('linux-x86_64',     'linux_64_n'), # new(er)
              'testbed15':('windows-x86_64',   'windows_64_2008_w7'),
              'testbed16-1':('linux-x86_64',   'linux_64_v1'),
              'testbed16-2':('linux-x86_64',   'linux_64_v2'),
              'testbed16-3':('windows-x86_64', 'windows_64_2008_v1'),
              'testbed16-4':('windows-x86_64', 'windows_64_2008_v2'),
              'testbed16-5':('windows-x86_64', 'windows_64_2003_v1'),
              'testbed17':('windows-x86_64',   'windows_64_2008rc2'),
              'symc-beast':('windows-x86_64',  'windows_64_2008_b'),
              'symc-beast2':('windows-x86_64', 'windows_64_2008_b2'),
              'symc-slim':('windows-x86_64',   'windows_64_2008_s'),
              'symc-slim2':('windows-x86_64',  'windows_64_2008_s2'),
              'testbed6-11':('windows-x86_64', 'windows_64_2003_v2'),
              'win2012-dev':('windows-x86_64', 'windows_64_2012_v1'),
              'redhat6-testbed':('linux-x86_64','linux_64_rhel63'),
              'sles-11-ide-reg':('linux-x86_64','linux_64_suse11'),
              'testbed-2012-2':('windows-x86_64','windows_2012_v2')}

FROM = os.getlogin() + '@vivisimo.com'
TO = [FROM]
CC = ['qa-pool@vivisimo.com']

def notify(subject, body):
    header = {'Date':time.strftime('%d %b %Y %X %Z'),
              'From':FROM,
              'To':', '.join(TO),
              'CC':', '.join(CC),
              'Subject':subject}
    msg = '\r\n'.join(['%s: %s' % item for item in header.items()]) \
        + '\r\n\r\n' + body + '\r\n'
    server = smtplib.SMTP('localhost')
    server.sendmail(FROM, TO+CC, msg)
    server.quit()


def platform(target):
    return TARGET_MAP[target][0]

def description(target):
    return TARGET_MAP[target][1]

def windows(target):
    return platform(target).startswith('windows')

def solaris(target):
    return platform(target).startswith('solaris')

def major_minor_build(version):
    parts = version.split('-',2) + ['', '', '']
    return parts[:3]

def major(version):
    """Make sure to return a valid number."""
    t = major_minor_build(version)[0]
    try:
        f = float(t)
    except:
        return '99.9'
    return t


def major_minor(version):
    return '-'.join(major_minor_build(version)[:2])

def build(version):
    return major_minor_build(version)[2]


def installer_available(version, target):
    install_dir = '/candidates/velocity/' + version

    try:
        available_installers = os.listdir(install_dir)
    except OSError:
        return False

    for installer in available_installers:
        if platform(target) in installer:
            return True
    return False


def do_installation(version, target):
    cmd = 'do_install ' + version
    bash_script = ['source env.setup/%s' % target, cmd]
    process = subprocess.Popen('/bin/bash',
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT)
    process.stdin.write('\n'.join(bash_script) + '\n')
    stdout, stderr = process.communicate()
    process.stdin.close()
    status = process.poll()
    if status:
        msg = 'Failed'
    else:
        msg = 'Successful'
    # Return status, email-subject, email-body
    return status, \
        '%s install of %s on %s' % (msg, version, target), \
        '%s\nstatus = %d\n%s' % (cmd, status, stdout)


def launch_regressions(version, target):
    directory = os.path.join('../testrun', target)
    try:
        os.mkdir('../testrun')  # Try to assure the output directory is there.
    except OSError:             # Don't worry about errors:
        pass                    # probably already there.
    try:
        os.mkdir(directory)     # Try to assure the output directory is there.
    except OSError:             # Don't worry about errors:
        pass                    # probably already there.
    if windows(target):
        testlist = 'winlist.vtd'
    elif solaris(target):
        testlist = 'sunlist.vtd'
    else:
        testlist = 'testlist.vtd'

    vtd_command = VTD % (testlist, os.path.join(NEW_RESULTS,
                                                description(target),
                                                version))
    bash_script = ['source env.setup/%s' % target,
                   'export VIVVERSION=%s' % major(version),
                   'export VIVRELEASE=%s' % major_minor(version),
                   'export VIVBUILD=%s' % build(version),
                   '/bin/mkdir -p %s' % directory,
                   '/bin/cp %s %s || exit' % (os.path.join('testrun', testlist),
                                              directory),
                   'cd %s' % directory,
                   'echo "%s"' % vtd_command,
                   vtd_command]
    process = subprocess.Popen('/bin/bash',
                               stdin=subprocess.PIPE,
                               stdout=open('%s/vtd.log' % directory, 'a'),
                               stderr=subprocess.STDOUT)
    process.stdin.write('\n'.join(bash_script) + '\n')
    process.stdin.close()
    return '%s: %s regressions started' % (target, version), vtd_command


def attempt_run(version, target):
    """Attempt to install. If the install was successful, kick off the
    regressions.

    Send a single email in either case."""
    status, install_subject, install_body = do_installation(version, target)
    if status:
        notify(install_subject, install_body)
    else:
        regress_subject, regress_body = launch_regressions(version, target)
        notify(regress_subject,
               '%s\n\n%s' % (regress_body, install_body))


def validate(version, target_list):
    """Basic sanity checks on the requested targets."""
    for target in target_list:
        assert TARGET_MAP.has_key(target), 'Unknown target %s.' % target

    for target in target_list:
        setup_path = 'env.setup/%s' % target
        assert os.path.exists(setup_path), \
            'Environment setup script "%s" not found.' % setup_path


def main(version, target_list):
    threads = []
    validate(version, target_list)
    pending_targets = set(target_list)
    while pending_targets:
        for target in frozenset(pending_targets):
            if installer_available(version, target):
                pending_targets.remove(target)
                t = threading.Thread(target=attempt_run,
                                     args=(version, target))
                t.setDaemon(True)
                t.start()
                threads.append(t)
        sys.stdout.flush()
        time.sleep(SLEEP_TIME - (time.time() % SLEEP_TIME))
    # Wait for any outstanding threads to complete.
    for t in threads:
        t.join()


if __name__ == "__main__":
    # Allow the user to use Control-C to immediately stop the whole program.
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    # FIXME should accept various options to pass through to 'vtd'.
    main(sys.argv[1], sys.argv[2:])
