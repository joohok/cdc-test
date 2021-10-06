#!/bin/sh
# delete05 : REC_HOME insert | REC_HOME UPDATE  -> To Make REC_RELOCATION -> DELETE REC_RELOCATION  
set -x

db=delete05db
filename=delete05
statement='CREATE TABLE delete05 (id int,b char (200), c varchar(200))'
statement2="INSERT INTO delete05 values (100, 'aa', 'asd')"
statement3="UPDATE delete05 set c='asdfasdfadfasdfasdfasfasdfasfasfasdfasfasfasdfasfdasfasfasfasfas' where id=100"
statement4='DELETE FROM delete05'
count=1000

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
cubrid broker start 
gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -c "$statement"

for ((i=1;i <=${count};i++))
do
  csql -u dba $db -c "$statement2"
done 

csql -u dba $db -c "$statement3"
csql -u dba $db -c "$statement4"

./${filename} localhost 1523 $db 0 &> ${filename}.result
#./${filename} localhost 1523 $db 0 

#03. data check. 
 
if [ `grep "num_cond_column : 3" ${filename}.result |wc -l` -eq $count ]
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


