#!/bin/sh
set -x

filename=api21
tracelog=./tracelog

touch tracelog

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} $tracelog 1 10 &>> ${filename}.result
#./${filename} $tracelog tracelog_level tracelog_size &>> ${filename}.result

if [ `grep 'FAIL' ${filename}.result |wc -l` -eq 1 ]
then
	echo 'PASS '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL '$filename'' >> $CDC_TEST/result
fi

rm $filename
rm ${filename}.result
rm tracelog*
rm csql.err
rm core*
