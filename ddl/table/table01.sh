#!/bin/sh
set -x

db=table01db
filename=table01
statement="create table table01 (a int)"
statement2="rename table table01 as table01a"
statement3="alter table table01a add column b int"
statement4="truncate table01a"
statement5="drop table table01a"

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "cdc_logging_debug=1" >>$CUBRID/conf/cubrid.conf
echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid broker start 
cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -c "$statement"

javac OID_Sample.java
java OID_Sample > classoid.txt
classoid=`cat classoid.txt`

csql -u dba $db -i table01.sql 

./${filename} localhost 1523 $db 0 &> ${filename}.result
#./${filename} localhost 1523 $db 0 


#01 DDL check 
if [ `grep "DDL SUCCESS" ${filename}.result |wc -l` -eq 5 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

#02 classoid check 
if [ `grep "$classoid" ${filename}.result |wc -l` -eq 5 ]
then
	echo 'PASS02 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' >> $CDC_TEST/result
fi

#03 statement check 
if [ `grep "$statement" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "$statement2" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "$statement3" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "$statement4" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "$statement5" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

#04 FAIL check 
if [ `grep "FAIL" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS04 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL04 '$filename'' >> $CDC_TEST/result
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
rm classoid.txt 
rm csql.*
