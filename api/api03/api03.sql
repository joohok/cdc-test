#!/bin/bash 

csql -u dba testdb -c 'drop table if exists api03;'
sleep 1

csql -u dba testdb -c 'create table api03 (id int not null primary key);'

for (( i=0;i<5; i++)); do
  csql -u dba testdb -c "insert into api03 value ($i)" &> /dev/null
done

