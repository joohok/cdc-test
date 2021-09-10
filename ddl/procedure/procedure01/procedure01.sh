#!/bin/sh
set -x

db=procedure01db
filename=procedure01
statement="CREATE FUNCTION hello() RETURN STRING AS LANGUAGE JAVA NAME 'SpCubrid.HelloCubrid() return java.lang.String'"

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
echo "java_stored_procedure=yes" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
cubrid javasp start $db

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

echo -e 'y'| loadjava $db SpCubrid.class

csql -u dba $db -c "$statement"

./${filename} localhost 1523 $db 0 &> ${filename}.result

if [ `grep "DDL SUCCESS" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "$statement" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS02 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "FAIL" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 
cubrid javasp stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
rm -rf java
