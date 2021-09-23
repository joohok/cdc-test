#!/bin/sh
set -x

db=oper03db
filename=oper03
#oper03_1 : get LSA / 
#oper03_2 : cubrid_log_extract with lsa received from oper03_1 
#oper03_3 : cubrid_log_extract with invalid lsa (random lsa)
#oper03_4 : cubrid_log_extract with far previous lsa (lsa from oper03_1, and exract with the lsa after extracting several times).
filename1=oper03_1
filename2=oper03_2
filename3=oper03_3
filename4=oper03_4

statement='CREATE TABLE oper03 (id int)'
statement2='INSERT INTO oper03 values (100)'
count=5

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

gcc -g -o ${filename1} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename1}.c
gcc -g -o ${filename2} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename2}.c
gcc -g -o ${filename3} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename3}.c
gcc -g -o ${filename4} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename4}.c

./${filename1} localhost 1523 $db 0 &> lsa.result &&
lsa=`cat lsa.result`

./${filename2} localhost 1523 $db $lsa &>>  ${filename}.result
./${filename3} localhost 1523 $db $lsa &>>  ${filename}.result
./${filename4} localhost 1523 $db $lsa &>>  ${filename}.result
#./${filename} localhost 1523 $db 0 

#4 error check 
if [ `grep "$lsa" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS04 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL04 '$filename'' >> $CDC_TEST/result
fi

#4 error check 
if [ `grep "ERROR" ${filename}.result |wc -l` -eq 2 ]
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
rm $filename3
rm $filename4
rm ${filename}.result
rm lsa.result
rm cubrid_tracelog.err
