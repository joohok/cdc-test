#!/bin/sh
set -x

db=supp19db
filename=supp19

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=0" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid server start $db 
cubrid broker start 

csql -u dba $db -i supp19.sql &&

cubrid server stop $db 
cubrid broker stop &&

echo -e "0\n -1\n 10\n -1\n y\n" | cubrid diagdb ${db} -d 8 -o ${filename}.result &&

#tran user
if [ `grep "SUPPLEMENT TYPE = 0" ${filename}.result |wc -l` -eq 2 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

#undo record 
if [ `grep "SUPPLEMENT TYPE = 1" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS02 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' >> $CDC_TEST/result
fi

# DDL
if [ `grep "SUPPLEMENT TYPE = 2" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

#INSERT, UPDATE, DELETE 
if [ `grep "SUPPLEMENT TYPE = 3" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS04 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL04 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "SUPPLEMENT TYPE = 4" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS05 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL05 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "SUPPLEMENT TYPE = 5" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS06 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL06 '$filename'' >> $CDC_TEST/result
fi

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/
rm ${filename}.result
rm csql.err
