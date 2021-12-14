#!/bin/sh
set -x

filename=api27
tracelog=./tracelog

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

#1. tracelog level will be 0 or 1, if not it fails
# SUCCESS, FAIL, FAIL 
./${filename}  $tracelog 1 10 &>> ${filename}.result
./${filename}  $tracelog -1 10 &>> ${filename}.result
./${filename}  $tracelog 2 10 &>> ${filename}.result

#2. tracelog size : 8<= size <= 512
# FAIL, SUCCESS, FAIL
./${filename}  $tracelog 1 7 &>> ${filename}.result
./${filename}  $tracelog 1 10 &>> ${filename}.result
./${filename}  $tracelog 1 513 &>> ${filename}.result

if [ `grep 'FAIL' ${filename}.result |wc -l` -eq 4 ]
then
	echo 'PASS '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL '$filename'' >> $CDC_TEST/result
fi

rm $filename
rm ${filename}.result
rm -rf tracelog*
rm core*
