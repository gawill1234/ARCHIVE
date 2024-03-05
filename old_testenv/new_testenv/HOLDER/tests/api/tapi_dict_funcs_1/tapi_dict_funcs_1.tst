#!/bin/bash

echo $CLASSPATH

if [ -f tapi_dict_funcs_1.class ]; then
   rm tapi_dict_funcs_1.class
fi

if [ -f tapi_dict_funcs_1.java ]; then
   javac tapi_dict_funcs_1.java
else
   echo "tapi_dict_funcs_1:  file tapi_dict_funcs_1.java is missing"
fi

if [ -f tapi_dict_funcs_1.class ]; then
   java tapi_dict_funcs_1 --collection-name repotest
   blah=$?

   rm tapi_dict_funcs_1.class

else
   echo "tapi_dict_funcs_1:  file tapi_dict_funcs_1.class is missing"
fi

if [ $blah -eq 0 ]; then
   echo "tapi_dict_funcs_1:  Test Passed"
   exit 0
fi

echo "tapi_dict_funcs_1:  Test Failed"
exit 1
