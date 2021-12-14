#!/bin/sh
set -x

filename=api25
tracelog=./tracelog

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

mkdir tracelog
chmod 555 tracelog

./${filename}  $tracelog 1 10 &>> ${filename}.result

if [ `grep 'FAIL' ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL '$filename'' >> $CDC_TEST/result
fi

rm $filename
rm ${filename}.result
rm -rf tracelog*
rm core*
