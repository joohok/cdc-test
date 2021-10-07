#!/bin/sh
set -x

db=api08db
filename=api08

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} localhost 1523 $db > ${filename}.result &
./${filename} localhost 1523 $db >> ${filename}.result

if [ `grep "FAIL" api08.result |wc -l` -eq 1 ]
then
	echo 'PASS api08' >> $CDC_TEST/result
else
	echo 'FAIL api08' >> $CDC_TEST/result
fi

cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm core*
rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
