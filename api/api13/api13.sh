#!/bin/sh
set -x

db=api13db
filename=api13
filename2=api13_2
filename3=api13_3


cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c
gcc -g -o ${filename2} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename3}.c
gcc -g -o ${filename3} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename2}.c

./${filename} localhost 1523 $db 0 &> ${filename}.result
./${filename2} localhost 1523 $db 0 &>> ${filename}.result
./${filename3} localhost 1523 $db 0 &>> ${filename}.result

if [ `grep 'ERROR' ${filename}.result |wc -l` -eq 3 ]
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
rm $filename2
rm $filename3
rm ${filename}.result
rm cubrid_tracelog.err
rm core*
