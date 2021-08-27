#!/bin/bash 

count=${1}

csql -u dba testdb -c 'drop table if exists ins03;'
sleep 1

csql -u dba testdb -c 'create table ins03 (a char(5), b varchar(50));'

csql -u dba testdb -c "insert into ins03 values ('aa', 'aaaaaaaaaaaaa')"
csql -u dba testdb -c "insert into ins03 values ('bb', 'bbbbbbbbbbbbb')"
csql -u dba testdb -c "insert into ins03 values ('cc', 'ccccccccccccc')" 

csql -u dba testdb -c "select count(*) from ins03"
