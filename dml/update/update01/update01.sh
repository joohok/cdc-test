#!/bin/sh
set -x

db=update01db
filename=update01
count=1000

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
echo "cdc_logging_debug=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
cubrid broker start &&

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -i update01-create.sql
csql -u dba $db -i update01-insert.sql

for ((i=1;i <=${count};i++))
do
  csql -u dba $db -c "update update01 set a = $((i+1)) where a =${i} ;"
done 

javac OID_Sample.java
java OID_Sample > classoid.txt
classoid=`cat classoid.txt`

./${filename} localhost 1523 $db 0 &> ${filename}.result
#./${filename} localhost 1523 $db 0 

#01 insert count check 
if [ `grep "DML SUCCESS" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

#02 classoid check 
if [ `grep "$classoid" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS02 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' >> $CDC_TEST/result
fi

#03. data check. 
 
if [ `grep "num_cond_column: 17" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "cond_column_data\[1]: 10.100000" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "cond_column_data\[2]: 10.101000" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi


if [ `grep "cond_column_data\[3]: aa" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "cond_column_data\[4]: aaa" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "cond_column_data\[5]: X'8'" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "cond_column_data\[6]: X'a'" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "cond_column_data\[7]: 2021-09-13 12:30" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "cond_column_data\[8]: 2021-09-13 12:30:00 +09:00" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "cond_column_data\[9]: 2021-09-13 12:30:00.000" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "cond_column_data\[10]: 2021-09-13 12:30:00.000 +09:00" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "cond_column_data\[11]: 2021-09-13" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "cond_column_data\[12]: 13:15:45" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "cond_column_data\[13]: file:/home/joohok/cdc-tests/dml/update/update01/lob/" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "cond_column_data\[14]: file:/home/joohok/cdc-tests/dml/update/update01/lob/" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "cond_column_data\[15]: 1010.00000" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
if [ `grep "cond_column_data\[16]: cdc" ${filename}.result |wc -l` -eq ${count} ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi
#4 error check 
if [ `grep "ERROR" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS04 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL04 '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 
cubrid broker stop 
cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
#rm ${filename}.result
rm cubrid_tracelog.err
rm classoid.txt
