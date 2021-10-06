#!/bin/sh
set -x

db=api21db
filename=api21
tracelog=~/cdc-tests/tracelog.err

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

#echo "cdc_logging_debug=1" >> $CUBRID/conf/cubrid.conf 
echo "supplemental_log=1" >> $CUBRID/conf/cubrid.conf

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} localhost 1523 $db . -1 10 
./${filename} localhost 1523 $db $tracelog -1 10 
./${filename} localhost 1523 $db $tracelog 1 10 
#./${filename} localhost 1523 $db . -1 10 &> ${filename}.result
#./${filename} localhost 1523 $db $tracelog -1 10 &>> ${filename}.result
#./${filename} localhost 1523 $db $tracelog 1 10 &>> ${filename}.result
#./${filename} localhost 1523 $db 1629775990 

if [ `grep 'FAIL' ${filename}.result |wc -l` -eq 2 ]
then
	echo 'PASS '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL '$filename'' >> $CDC_TEST/result
fi

FILESIZE=$(stat -c%s "$tracelog")

if [$FILESIZE -eq 10485760]
then
	echo 'PASS '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
rm tracelog*
rm csql.err
rm core*
