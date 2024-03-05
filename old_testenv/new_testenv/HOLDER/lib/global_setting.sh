#!/bin/bash

#####################################################################

###
#   Global stuff
#   This file defines the global settings required by all 
#   crawl/query tests.
###

   export PATH=$PATH:$TEST_ROOT/utils/bin:$TEST_ROOT/bin

   SHOST=$VIVHOST
   VUSER=$VIVUSER
   VPW=$VIVPW
   VPORT=$VIVPORT
   TARGETOS=$VIVTARGETOS

   results=0
   casecount=0
   query_pid_count=0
   mkdir -p logs
   mkdir -p querywork

#####################################################################
