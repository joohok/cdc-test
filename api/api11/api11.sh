#!/bin/sh
set -x

db=api11db
filename=api11

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori
echo 'supplemental_log=1' >> $CUBRID/conf/cubrid.conf

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} localhost 1523 $db 0 &> ${filename}.result 

#./${filename} localhost 1523 $db 0 

if [ `grep "TIMER SUCCESS" ${filename}.result |wc -l` -ne 0 ]
then
	echo 'PASS1 api11' >> $CDC_TEST/result
else
	echo 'FAIL1 api11' >> $CDC_TEST/result
fi

if [ `grep "FAIL" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS2 api11' >> $CDC_TEST/result
else
	echo 'FAIL2 api11' >> $CDC_TEST/result
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
rm csql.err
