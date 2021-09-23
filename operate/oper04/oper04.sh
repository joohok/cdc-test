#!/bin/sh
set -x

db=oper04db
filename=oper04
#oper04_1 : get LSA / 
#oper04_2 : cubrid_log_extract with lsa received from oper04_1 
filename1=oper04_1
filename2=oper04_2

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

gcc -g -o ${filename1} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename1}.c
gcc -g -o ${filename2} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename2}.c

./${filename1} localhost 1523 $db 0 &> lsa.result &&
lsa=`cat lsa.result`

cubrid server restart $db

./${filename2} localhost 1523 $db $lsa &>>  ${filename}.result
#./${filename} localhost 1523 $db 0 

#4 error check 
if [ `grep "$lsa" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS04 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL04 '$filename'' >> $CDC_TEST/result
fi

#4 error check 
if [ `grep "ERROR" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS04 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL04 '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 
cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename1
rm $filename2
rm ${filename}.result
rm lsa.result
rm cubrid_tracelog.err
