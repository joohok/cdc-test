#!/bin/sh
set -x

db=supp12db
filename=supp12

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
cubrid broker start 

echo "supplemental_log=0" >>$CUBRID/conf/cubrid.conf && 

cubrid broker restart

csql -u dba $db -i supp12.sql &&

cubrid server stop $db 
cubrid broker stop &&

echo -e "0\n -1\n 1\n -1\n y\n" | cubrid diagdb ${db} -d 8 -o ${filename}.result &&

#01 DDL supplement check 
if [ `grep "SUPPLEMENT TYPE = 2" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

#02 INSERT supplement check 
if [ `grep "SUPPLEMENT TYPE = 3" ${filename}.result |wc -l` -ne 0 ]
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
