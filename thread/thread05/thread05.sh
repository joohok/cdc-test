#!/bin/sh
set -x

db=thread05db
filename=thread05
statement='CREATE TABLE thread05 (id int)'
statement2='INSERT INTO thread05 values (100)'
count=5

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -c "$statement"

for ((i=1;i <=${count};i++))
do
  csql -u dba $db -c "$statement2"
done 

./${filename} localhost 1523 $db 0 &
#./${filename} localhost 1523 $db 0 

cubrid server stop $db &> ${filename}.result  

#4 error check 
if [ `grep "fail" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

cubrid broker stop 
cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
rm csql.err
