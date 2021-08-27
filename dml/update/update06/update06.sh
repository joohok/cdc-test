#!/bin/sh
set -x

db=update06db
filename=update06
statement='CREATE TABLE update06 (id int, c char(255000))'
statement2='INSERT INTO update06 values (100, 'ac')'
statement3='UPDATE update06 SET id=10 WHERE id=100'
count=10

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M


gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -S -c  "$statement"
for((i=0;i<${count};i++))
do
  csql -u dba $db -c  "$statement2" 
done

csql -u dba $db -c  "$statement3"

cubrid server start $db 
./${filename} localhost 1523 $db 0 &> ${filename}.result

if [ `grep "DML SUCCESS" ${filename}.result |wc -l` -eq $count+$count ]
then
	echo 'PASS01 '$filename'' > $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' > $CDC_TEST/result
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
