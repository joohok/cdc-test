#!/bin/sh
set -x

db=supp18db
filename=supp18

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

cubrid paramdump $db -o ${filename}.result

csql -u dba $db -i supp18.sql >> ${filename}.result

cubrid server stop $db

if [ `grep "supplemental_log" ${filename}.result |wc -l` -eq 2 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/
rm ${filename}.result
rm csql.err
