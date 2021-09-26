#!/bin/sh
set -x

db=oper06db
filename=oper06

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

csql -u dba $db -c 'create table oper06 (a int);'
csql -u dba $db -c 'insert into oper06 values (10);'

cubrid server stop $db 

cubrid backupdb -S $db 

cubrid restoredb $db 

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} localhost 1523 $db 0 &> ${filename}.result

#./${filename} localhost 1523 $db 0 

# DDL check 
if [ `grep "DDL SUCCESS" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

# DML check 
if [ `grep "DML SUCCESS" ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

# error check 
if [ `grep "ERROR" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 
cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
rm csql.err
rm ${db}_*
