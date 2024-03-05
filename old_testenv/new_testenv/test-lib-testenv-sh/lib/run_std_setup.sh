#!/bin/bash

#####################################################################

###
#   This defines the standard test setup for all of the
#   crawl/query tests.
###

getsetopts $*

cleanup $SHOST $VCOLLECTION $VUSER $VPW
setup $SHOST $VCOLLECTION $VUSER $VPW

#####################################################################
