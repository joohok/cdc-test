#!/bin/sh
set -x

db=ddl02db
filename=ddl02

#is32bit=`file ${CUBRID}/bin/cubrid | grep "32-bit" | wc -l`

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori
#sed -i 's/data_/#data_/g' $CUBRID/conf/cubrid.conf

#echo "data_buffer_size=512M" >>$CUBRID/conf/cubrid.conf
#echo "[@$db2]" >>$CUBRID/conf/cubrid.conf
#echo "data_buffer_size=768M" >>$CUBRID/conf/cubrid.conf

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M
#cubrid_createdb $db2 

echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf

cubrid server start $db 

sh ddl02.sql

sleep 1
#grep classoid by jdbc 
gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

#./${filename} localhost 1523 $db 1629775990 > ${filename}.result
./${filename} localhost 1523 $db 0

if [ `grep 'DML SUCCESS' ${filename}.result |wc -l` -eq 12 ]
then
	echo 'PASS '$filename'' > $CDC_TEST/result
else
	echo 'FAIL '$filename'' > $CDC_TEST/result
fi

if [ `grep 'FAIL' ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS '$filename'' > $CDC_TEST/result
else
	echo 'FAIL '$filename'' > $CDC_TEST/result
fi



cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

#rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
