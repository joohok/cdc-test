#!/bin/sh
set -x

db=oper07db
db1=oper07db1
filename=oper07

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

csql -u dba $db -c 'create table oper07 (a int);'

for((i=0;i<100;i++))
do
  csql -u dba $db -c 'insert into oper07 values (10);'
done

cubrid unloaddb $db 

cubrid server stop $db 

cubrid deletedb $db

cubrid createdb $db1 en_US --db-volume-size=128M --log-volume-size=128M

cubrid start server $db1 

cubrid loaddb -C -u dba -d ${db}_objects -s ${db}_schema $db1

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} localhost 1523 $db1 0 &> ${filename}.result

#./${filename} localhost 1523 $db 0 

# DDL check 
if [ `grep "DDL SUCCESS" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

# DML check 
if [ `grep "DML SUCCESS" ${filename}.result |wc -l` -eq 100 ]
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

cubrid server stop $db1 
cubrid deletedb $db1 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
rm csql.err
rm ${db}_*
