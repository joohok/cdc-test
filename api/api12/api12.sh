#!/bin/sh
set -x

db=api12db
filename=api12
filename2=api12_2

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c
gcc -g -o ${filename2} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename2}.c

#./${filename} localhost 1523 $db -1
#./${filename2} localhost 1523 $db 0
./${filename} localhost 1523 $db -1 &> ${filename}.result
./${filename2} localhost 1523 $db 0 &>> ${filename}.result

if [ `grep "ERROR" ${filename}.result |wc -l` -eq 2 ]
then
	echo 'PASS api12' >> $CDC_TEST/result
else
	echo 'FAIL api12' >> $CDC_TEST/result
fi

cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm $filename2
rm ${filename}.result
rm cubrid_tracelog.err
rm core*
