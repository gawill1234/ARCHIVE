#!/bin/bash
#
#  $1 is HOST
#  $2 is USER
#  $3 is USER PW

while [ 1 ]; do
   sleep $4
   stop_query_service -H $1 -U $2 -P $3
   sleep $4
   start_query_service -H $1 -U $2 -P $3
done

exit 0
