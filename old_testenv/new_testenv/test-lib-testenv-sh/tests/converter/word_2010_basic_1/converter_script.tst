#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   This is the basic script which takes an argument as root directory and
#   run the converter test for every file under the root direcotory
#   This test does
#   A)  Trace every file under the given directory
#   B)  If the file extension matchs our testing file extension like doc, docx....
#   C)  Run the converter test for each file with its proper word list
#
#   This test requires the file and its word list should be under the same directory or the test will fail
#
#
#

import os, sys
import converter_test
from os import path
import converter_test_helper

if (len(sys.argv) != 3):
    print "Please give a root directory contains with test files and the output report file."
    print "ex: ./converter_script.tst /Converterfiles/ /tmp/report"
    sys.exit(1)

ROOT_DIR = sys.argv[1]
REPORT_FILE = sys.argv[2]

# We are running test on svl machine
SMB_HOST = 'bdvm255.svl.ibm.com'
SMB_USER = 'converter_user'
SMB_PASSWORD = 'c0nverter'

converter_test_helper.write_content_to_file(REPORT_FILE, '', 'w')
# Run the converter test for eash file under the root directory
for root, sub_folders, files in os.walk(ROOT_DIR):
    # These are file types that we are testing
    fileTypeList = ['csv', 'doc', 'docx', 'fodg', 'fodp', 'fods', 'fodt', \
                        'html', 'mpp', 'odf', 'odg', 'odp', 'ods', 'odt', 'pdf', \
                        'ppt', 'pptx', 'rtf', 'stw', 'sxc', 'sxd', 'sxg', 'sxi', \
                        'sxm','sxw', 'wpd', 'xls','xlsx']

    for file in files:
        inputfile = os.path.join(root,file)
        extension = os.path.splitext(inputfile)[1][1:].lower()

        # Make sure the file type is the one that we want to test
        if any(extension in fileTypeList for word in fileTypeList):
            wordfile = inputfile + '.words'

            # If there is no proper word list, skip
            if not path.exists(wordfile):
                print "no wordlist of " + inputfile
                converter_test_helper.write_content_to_file(REPORT_FILE, inputfile + ' failed code = 5 no wordlist ' + '\n', 'a')
            else:

                # Run converter query test for each file
                arg_list = ['-s', inputfile , '-w', wordfile]

                result = converter_test.main(arg_list)

                if result != 0:
                    converter_test_helper.write_content_to_file(REPORT_FILE, inputfile + ' failed code = ' + str(result) + '\n', 'a')


