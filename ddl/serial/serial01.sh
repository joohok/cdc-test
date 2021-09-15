#!/bin/sh
set -x

db=serial01db
filename=serial01

statement="create serial serial01"
statement2="alter serial serial01 start with 10"
statement3="select serial_next_value(serial01, 10)"
statement4="drop serial serial01"
 
cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -c "create table serial01a (a int)"

javac OID_Sample.java
java OID_Sample > classoid.txt
classoid=`cat classoid.txt`

csql -u dba $db -i serial01.sql 

#./${filename} localhost 1523 $db 0 &> ${filename}.result
./${filename} localhost 1523 $db 0 


#01 DDL check 
if [ `grep "DDL SUCCESS" ${filename}.result |wc -l` -eq 3 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

#02 classoid check 
if [ `grep "$classoid" ${filename}.result |wc -l` -eq 3 ]
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

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
rm classoid.txt 
rm csql.*
