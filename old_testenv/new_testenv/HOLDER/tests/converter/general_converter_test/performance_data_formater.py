#!/usr/bin/python
# encoding: utf-8

#
# This is the script to merge testing time information into a CSV file.
# The converter test generates a '.time' file recording the crawling time of
# a collection for every test.
# This script takes a path that contains '.time' files using old converters
# and anoter path that contains '.time' files using new converters.
# This script goes through all '.time' files, reads the testing time from them
# and write to a CSV file. And it calculates the average, max, min difference
# between the same test file. And calculates the correlation of two tests.
#


import os, sys
import math
from optparse import OptionParser
import random
import converter_test_helper

reload(sys)
sys.setdefaultencoding("utf-8")

time_file_extention = "time"

old_time = {}
new_time = {}

#
# Get Arguments from clients
#
def get_arguments():
    parser = OptionParser(usage= "\n" + \
                              "%prog -o [Old test time file or directory path] " +\
                              "-n [New test time file or directory path] " +\
                              "-d [Output CSV file path]",
                            version="%prog 1.0")
    parser.add_option("-o", "--old", dest="old_time_file_path",help="Old test time file or folder path")
    parser.add_option("-n", "--new", dest="new_time_file_path",help="New test time file or folder path")
    parser.add_option("-d", "--destination", dest="destination",help="Output CSV file path")
    parser.add_option("-q", "--quiet",action="store_false", dest="verbose", default=True,help="don't print status messages to stdout")
    (options, args) = parser.parse_args()

    if options.old_time_file_path == None:
        parser.error("Please specify the path of old test time file or directory.\n")
    if options.new_time_file_path == None:
        parser.error("Please specify the path of new test time file or directory.\n")
    if options.destination == None:
        parser.error("Please specify the path of output CSV file.\n")

    return options

#
# Check the given path existing
#
def check_path_existing(path):
    if not os.path.exists(path):
        print 'Can\'t find path: ' + path
        sys.exit(1)

#
# Check the given object not None
#
def check_object_not_none(obj, object_name):
    if obj == None:
        print 'Object:[{0}] is none.'.format(object_name)
        sys.exit(1)
#
# Read testing time from a given '.time' file or a directory
# put the testing time into a dictionary object 'store'
#
def read_test_time_files(path, store):
    check_path_existing(path)
    check_object_not_none(store, 'store')
    if os.path.isdir(path):
        read_test_time_files_from_dir(path, store)
    else:
        read_testing_time_from_file(path, store)

#
# Go through a given directory
# read testing time from '.time' files
# and put into a dictionary object 'store'
#
def read_test_time_files_from_dir(path, store):
    check_path_existing(path)
    check_object_not_none(store, 'store')

    for root, subFolders, files in os.walk(path):
        for file in files:
            extension = os.path.splitext(file)[1][1:].lower()
            if extension == time_file_extention:
                read_testing_time_from_file(os.path.join(root,file), store)

#
# Read testing time from a given '.time' file
# and put into a dictionary object 'store'
#
def read_testing_time_from_file(path, store):
    check_path_existing(path)
    check_object_not_none(store, 'store')

    time_file = converter_test_helper.open_data_file(path)
    time = time_file.read()
    time_file.close()
    store[path] = time

#
# Write testing time data of all tests into a CSV file
# First column is the tested file name
# Second column is the old testing time
# Third column is the new testing time
# Forth column is the difference of new testing time and old testing time
# The average, maximum and minimum differences are also in the output file.
# And the last line is the correlation of old testing time and new testing time.
#
def make_csv_file(output_file_path):
    format_string = '{0},{1},{2},{3}\n'
    csv_file = open(output_file_path, 'w')
    old_time_list = []
    new_time_list = []
    diff = []
    for key in sorted(old_time.iterkeys()):
        if key in new_time:
            floated_old_time = float(old_time[key])
            old_time_list.append(floated_old_time)

            floated_new_time = float(new_time[key])
            new_time_list.append(floated_new_time)

            diff.append(floated_new_time-floated_old_time)

            csv_file.write(format_string.format(key, old_time[key], new_time[key], str(floated_new_time-floated_old_time)))

    avg_diff = sum(diff) / len(diff)
    max_diff = max(diff)
    min_diff = min(diff)
    correlation = get_correlation(old_time_list, new_time_list)

    csv_file.write("average diff,"+str(avg_diff)+"\n")
    csv_file.write("max diff,"+str(max_diff)+"\n")
    csv_file.write("min diff,"+str(min_diff)+"\n")
    csv_file.write("correlation,"+str(math.fabs(correlation))+"\n")

    csv_file.close()

#
# Get the correlation of two float list objects
#
def get_correlation(listX, listY):
    check_object_not_none(listX, 'listX')
    check_object_not_none(listY, 'listY')

    length_x = len(listX)
    length_y = len(listY)

    # Make sure listX and listY have the same size.
    # The correlation is defined on two lists in the same size.
    if length_x!=length_y:
        return -1

    avg_x = sum(listX) / length_x
    avg_y = sum(listY) / length_y

    numerator = 0
    denominator = 0
    denominator_factor1 = 0
    denominator_factor2 = 0
    for i in range(length_x):
        factor1 = (listX[i] - avg_x)
        factor2 = (listY[i] - avg_y)
        numerator += factor1 * factor2
        denominator_factor1 += factor1 * factor1
        denominator_factor2 += factor2 * factor2
    denominator = math.sqrt(denominator_factor1) * math.sqrt(denominator_factor2)

    correlation = numerator / denominator

    return correlation

def main():
    options = get_arguments()
    old_time_file_path = options.old_time_file_path
    new_time_file_path = options.new_time_file_path
    destination = options.destination

    read_test_time_files(old_time_file_path, old_time)
    read_test_time_files(new_time_file_path, new_time)

    make_csv_file(destination)

if __name__ == "__main__":
    sys.exit(main())


