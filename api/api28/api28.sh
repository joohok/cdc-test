#!/bin/sh
set -x

db=api28db
filename=api28
tracelog=./tracelog

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori 

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M 

echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf 

cubrid server start $db

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

# check that tracelog file is created

#./${filename} $tracelog $tracelog_level $tracelog_size $hostname $port $db &>> ${filename}.result
./${filename}  $tracelog 1 10 localhost 1523 $db &>> ${filename}.result

if [ `grep 'FAIL' ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL '$filename'' >> $CDC_TEST/result
fi

if [ `ls $tracelog | grep "${db}_cubridlog_"|wc -l` -eq 1 ]
then 
	echo 'PASS '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL '$filename'' >> $CDC_TEST/result
fi


cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf 
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf 

rm -rf lob/

rm $filename
rm ${filename}.result
rm -rf tracelog*
rm core*
