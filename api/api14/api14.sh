#!/bin/sh
set -x

db=api14db
filename=api14
filename2=api14_2

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf

cubrid server start $db 
cubrid broker start 
sh api14-create.sh
sh api14-insert.sh 

#grep classoid by jdbc 
javac OID_Sample.java
java OID_Sample > classoid.txt 
classoid=`cat classoid.txt`
echo "'$classoid'" 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c
gcc -g -o ${filename2} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename2}.c

#classoid != NULL but num class is 0 
./${filename} localhost 1523 $db 0 $classoid 0 &> ${filename}.result

#classoid NULL
./${filename2} localhost 1523 $db 0 $classoid 5 &>> ${filename}.result
#./${filename} localhost 1523 $db 0 $classoid 

if [ `grep 'ERROR' ${filename}.result |wc -l` -eq 2 ]
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
rm ${filename}.result
rm cubrid_tracelog.err
rm OID_Sample.class
rm classoid.txt
rm core*
