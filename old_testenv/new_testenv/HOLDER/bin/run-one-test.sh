#!/bin/bash

# Given a test name, run that test.
# This script assumes it is being run from the root of a testenv.git checkout.

test_name=$1

source env.setup/fill-out

# Spit out the environment for posterity...
env | sort

# Make sure test support stuff is setup/built.
make || exit

# Find the test script.
test_script=$(find tests -name "$test_name.tst")
test_source_dir=$(dirname $test_script)

run_dir=$test_name-$$
mkdir $run_dir || exit
rsync -rLpt "$test_source_dir/." "$run_dir" || exit

cd $run_dir
"./$test_name.tst"
