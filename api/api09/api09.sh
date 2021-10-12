#!/bin/sh
set -x

db=api09db
filename=api09

ssh 192.168.2.106 cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori 
ssh 192.168.2.106 echo "supplemental_log=1">>$CUBRID/conf/cubrid.conf 

ssh 192.168.2.106 cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

ssh -t 192.168.2.106 "cubrid server start $db 1>&2"

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} 192.168.2.106 1523 $db &> api09.result
#./${filename} 192.168.2.106 1523 $db 

if [ `grep "FAIL" api09.result |wc -l` -eq 0 ]
then
	echo 'PASS api09' >> $CDC_TEST/result
else
	echo 'FAIL api09' >> $CDC_TEST/result
fi

ssh 192.168.2.106 cubrid server stop $db 

ssh 192.168.2.106 cubrid deletedb $db 
ssh 192.168.2.106 mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

#rm -rf lob/

rm core*
rm $filename
rm ${filename}.result
