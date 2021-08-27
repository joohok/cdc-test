#!/bin/bash

host=${1}
port=${2}
dbname=${3}
start_time=${4}

filename=${0%.sh}
filename=${filename##run_}

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} $host $port $dbname $start_time   
