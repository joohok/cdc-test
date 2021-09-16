#!/bin/sh
set -x

db=supp01db
filename=supp01

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=0" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
cubrid broker start 

csql -u dba $db -i supp01.sql &&

cubrid server stop $db 
cubrid broker stop &&

echo -e "0\n -1\n 10\n -1\n y\n" | cubrid diagdb ${db} -d 8 -o ${filename}.result &&

if [ `grep "SUPPLEMENTAL" ${filename}.result |wc -l` -eq 0 ]
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
