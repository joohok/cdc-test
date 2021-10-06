#!/bin/sh
set -x

db=api07
filename=api07

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

csql -u dba $db -c 'create user joo groups dba;'
gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} localhost 1523 $db > api07.result

if [ `grep "FAIL" api07.result |wc -l` -eq 1 ]
then
	echo 'PASS api07' >> $CDC_TEST/result
else
	echo 'FAIL api07' >> $CDC_TEST/result
fi

cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm core*
rm $filename
rm ${filename}.result
