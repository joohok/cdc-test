#!/bin/sh
set -x

db=thread02db
filename=thread02
statement='CREATE TABLE thread02 (id int)'
statement2='INSERT INTO thread02 values (100)'
err_msg="produced queue size is over the limit"
count=2048

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
echo "cdc_logging_debug=1" >>$CUBRID/conf/cubrid.conf 

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
cubrid broker start 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -c "$statement"

for ((i=1;i <=${count};i++))
do
  csql -u dba $db -c "$statement2" &> /dev/null
done 

./${filename} localhost 1523 $db 0 &> ${filename}.result
#./${filename} localhost 1523 $db 0 

sleep 3 

cubrid server stop $db &>> ${filename}.result

if [ `grep "ERROR" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "fail" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS02 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "${err_msg}" $CUBRID/log/server/${db}_latest.err |wc -l` -eq 1 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
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

