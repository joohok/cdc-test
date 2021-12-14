#!/bin/sh
set -x

filename=api26
tracelog=./tracelog

mkdir tracelog
chmod 777 tracelog

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename}  $tracelog 1 10 &>> ${filename}.result

if [ `grep 'SUCCESS' ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL '$filename'' >> $CDC_TEST/result
fi

rm $filename
rm ${filename}.result
rm -rf tracelog*
rm core*
