#!/bin/sh
set -x

db=api04db
filename=api04

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf

cubrid server start $db 
cubrid broker start 
sh api04-create.sh
sh api04-insert.sh 

#grep classoid by jdbc 
javac OID_Sample.java
java OID_Sample > classoid.txt 
classoid=`cat classoid.txt`
echo "'$classoid'" 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} localhost 1523 $db 0 $classoid &> ${filename}.result
#./${filename} localhost 1523 $db 0 $classoid 

if [ `grep 'DML SUCCESS' ${filename}.result |wc -l` -eq 3 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

if [ `grep 'FAIL' ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS02 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
rm OID_Sample.class
rm classoid.txt
rm core*
