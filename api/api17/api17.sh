#!/bin/sh
set -x

db=api17db
filename=api17

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} 1025 &> ${filename}.result
./${filename} 0  &>> ${filename}.result

if [ `grep 'ERROR' ${filename}.result |wc -l` -eq 2 ]
then
	echo 'PASS2 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL2 '$filename'' >> $CDC_TEST/result
fi



cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
rm core*
