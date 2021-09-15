#!/bin/sh
set -x

db=api06db
filename=api06

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

#echo "cdc_logging_debug=1" >> $CUBRID/conf/cubrid.conf 
echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf

cubrid server start $db 

sh api06.sql 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} localhost 1523 $db 1629775990 > ${filename}.result
#./${filename} localhost 1523 $db 1629775990 

if [ `grep 'cond_column' ${filename}.result |wc -l` -eq 4 ]
then
	echo 'PASS '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL '$filename'' >> $CDC_TEST/result
fi

if [ `grep 'FAIL' ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
