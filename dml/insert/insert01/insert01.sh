#!/bin/sh
set -x

db=insert01db
filename=insert01
statement='CREATE TABLE insert01 (id int)'
statement2='INSERT INTO insert01 values (100)'
count=5

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
cubrid broker start 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -c  "$statement" 
for((i=0;i<${count};i++))
do
  csql -u dba $db -c  "$statement2" 
done

javac OID_Sample.java
java OID_Sample > classoid.txt
classoid=`cat classoid.txt`

./${filename} localhost 1523 $db 0 &> ${filename}.result

if [ `grep "DML SUCCESS" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "$classoid" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS02 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "ERROR" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
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
