#!/bin/sh
set -x

db=api18db
filename=api18

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf

cubrid server start $db 

sh api18-create.sh
for ((i=0;i<2;i++))
do
  sh api18-insert.sh &> /dev/null 
done

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} localhost 1523 $db 0 10 > ${filename}.result
#./${filename} localhost 1523 $db 0 100 &> ${filename}.result
#./${filename} localhost 1523 $db 0 1000 &> ${filename}.result

if [ `tail -1 ${filename}.result | grep "list size" ${filename}.result | awk -F'=' '{print $2}'` -ne 0 ]
then
	echo 'PASS2 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL2 '$filename'' >> $CDC_TEST/result
fi

if [ `grep '100' ${filename}.result |wc -l` -ne 0 ]
then
	echo 'PASS2 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL2 '$filename'' >> $CDC_TEST/result
fi

if [ `grep '1000' ${filename}.result |wc -l` -ne 0 ]
then
	echo 'PASS2 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL2 '$filename'' >> $CDC_TEST/result
fi

if [ `grep 'ERROR' ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS2 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL2 '$filename'' >> $CDC_TEST/result
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
