#!/bin/bash

./queryit.sh &
one=$!
./queryit.sh &
two=$!
./queryit.sh &
three=$!
./queryit.sh &
four=$!
./queryit.sh &
five=$!
./queryit.sh &
six=$!
./queryit.sh &
seven=$!
./queryit.sh &
eight=$!
./queryit.sh &
nine=$!
./queryit.sh &
ten=$!
./queryit.sh &
eleven=$!
./queryit.sh &
twelve=$!
./queryit.sh &
thirteen=$!
./queryit.sh &
fourteen=$!
./queryit.sh &
fifteen=$!
./queryit.sh &
sixteen=$!
./queryit.sh &
seventeen=$!
./queryit.sh &
eighteen=$!
./queryit.sh &
nineteen=$!
./queryit.sh &
twenty=$!

sleep 300

kill -9 $one $two $three $four $five
kill -9 $six $seven $eight $nine $ten
kill -9 $eleven $twelve $thirteen $fourteen $fifteen
kill -9 $sixteen $seventeen $eighteen $nineteen $twenty
