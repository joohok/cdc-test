#!/bin/sh
# update06 : REC_BIGONE insert/ REC_BIGONE update  
set -x

db=update06db
filename=update06
statement='CREATE TABLE update06 (id int, c char(200000))'
statement2="INSERT INTO update06 values (100, 'aa')"
statement3="update update06 set id=10 where id=100" 
count=5

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
#cubrid broker start 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -c "$statement"

for ((i=1;i <=${count};i++))
do
  csql -u dba $db -c "$statement2"
done 

csql -u dba $db -c "$statement3"

./${filename} localhost 1523 $db 0 &> ${filename}.result
#./${filename} localhost 1523 $db 0 

#01 insert count check 
if [ `grep "DML SUCCESS" ${filename}.result |wc -l` -eq 10 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

#03. data check. 
 
if [ `grep "num_changed_column: 2" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS02 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' >> $CDC_TEST/result
fi

#4 error check 
if [ `grep "ERROR" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 
#cubrid broker stop 
cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err


