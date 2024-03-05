#!/bin/bash

collection_name='korean-2'
test_description='Multi-threaded Korean Test'

cp ${collection_name}.xml.base ${collection_name}.xml

sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${collection_name}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${collection_name}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${collection_name}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${collection_name}.xml

$TEST_ROOT/lib/simple_query_result_count_test.py $0 "$test_description" $collection_name

rm ${collection_name}.xml
