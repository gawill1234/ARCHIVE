#!/bin/bash

cd querywork

while [ 1 ];do
   run_query -C $1 -H $2 -Q quick+brown -O /dev/null &
   x=`randstring`
   run_query -C $1 -H $2 -Q  $x /dev/null &
   x=`randstring`
   run_query -C $1 -H $2 -Q $x -O /dev/null
   wait
done

exit 0
