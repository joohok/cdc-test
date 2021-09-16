#!/bin/sh
set -x

db=supp17db
filename=supp17

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

echo "supplemental_log=1" >>$CUBRID/conf/cubrid_broker.conf

cubrid server start $db  
cubrid broker start &> ${filename}.result
cubrid server stop $db
cubrid broker stop

if [ `grep "invalid keyword" ${filename}.result |wc -l` -ne 0 ]
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
