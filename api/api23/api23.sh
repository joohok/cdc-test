#!/bin/sh
set -x

db=api23db
filename=api23


cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

for ((i=0;i<10;i++))
do
./${filename} localhost 1523 $db 0 &>> ${filename}.result
done
#./${filename} localhost 1523 $db 0 

if [ `grep 'ERROR' ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS02 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
rm core*
