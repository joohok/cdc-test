#!/bin/bash 

count=${1}

csql -u dba testdb -c 'drop table if exists del01;'
csql -u dba testdb -c 'create table del01 (id int);'

for (( i=0; i < $count; i++)); do
  csql -u dba testdb -c "insert into del01 value ($i)" &> /dev/null
done

csql -u dba testdb -c "select count(*) from del01"

csql -u dba testdb -c "delete from del01"
csql -u dba testdb -c "select count(*) from del01"
