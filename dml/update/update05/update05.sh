#!/bin/sh
# update05 : REC_HOME insert | REC_HOME UPDATE  -> To Make REC_RELOCATION 
set -x

db=update05db
filename=update05
statement='CREATE TABLE update05 (id int,b char (200), c varchar(200))'
statement2="INSERT INTO update05 values (100, 'aa', 'asd')"
statement3="UPDATE update05 set c='asdfasdfadfasdfasdfasfasdfasfasfasdfasfasfasdfasfdasfasfasfasfas' where id=100"
statement4="UPDATE update05 set c='asdfasdfadfasdfasdfasfasdfasfasfasdfasfasfasdfasfdasfasfasfasfasaaaaa' where id=100"
count=200

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 
#cubrid broker start 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -c "$statement"

for ((i=1;i <=${count};i++))
do
  csql -u dba $db -c "$statement2" &> /dev/null 
done 

csql -u dba $db -c "$statement3"
csql -u dba $db -c "$statement4"

./${filename} localhost 1523 $db 0 &> ${filename}.result
#./${filename} localhost 1523 $db 0 

#01 insert count check 
if [ `grep "DML SUCCESS" ${filename}.result |wc -l` -eq 600 ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

#2 error check 
if [ `grep "ERROR" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS02 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL02 '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 
#cubrid broker stop 
cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err


