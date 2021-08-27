#!/bin/sh
set -x

db=update02db
filename=update02
statement='CREATE TABLE update02 (id int, c char(10), v varchar(10))'
statement2='INSERT INTO update02 values (100, 'ac', 'acc')'
statement3='UPDATE update02 SET c='ddddd' WHERE id=100'
change_cnt=3

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -c  "$statement" 
csql -u dba $db -c  "$statement2" 
csql -u dba $db -c  "$statement3" 

./${filename} localhost 1523 $db 0 &> ${filename}.result

if [ `grep "DML SUCCESS" ${filename}.result |wc -l` -eq 2 ]
then
	echo 'PASS01 '$filename'' > $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' > $CDC_TEST/result
fi

if [ `grep "$change_cnt" ${filename}.result |wc -l` -eq 4 ]
then
	echo 'PASS02 '$filename'' > $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' > $CDC_TEST/result
fi

if [ `grep "ERROR" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS03 '$filename'' > $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' > $CDC_TEST/result
fi

cubrid server stop $db 
cubrid broker stop 
cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
