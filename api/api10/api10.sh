#!/bin/sh
set -x

db=api10db
filename=api10

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori 
echo 'supplemental_log=1'>>$CUBRID/conf/cubrid.conf 

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

#host = NULL
./${filename} &> api10.result
#port = -1
./${filename} localhost -1 &>> api10.result
#dbname = NULL
./${filename} localhost 1523 &>> api10.result
#user = NULL
./${filename} localhost 1523 $db &>> api10.result
#password = NULL 
./${filename} localhost 1523 $db dba &>> api10.result

if [ `grep "FAIL" api10.result |wc -l` -eq 5 ]
then
	echo 'PASS api10' >> $CDC_TEST/result
else
	echo 'FAIL api10' >> $CDC_TEST/result
fi

cubrid server stop $db 

cubrid deletedb $db 

mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm core*
rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
