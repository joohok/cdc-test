#!/bin/bash 

count=${1}

csql -u dba testdb -c 'drop table if exists del03;'

sleep 1

csql -u dba testdb -c 'create table del03 (a char(5), b varchar(50));'

csql -u dba testdb -c "insert into del03 values ('aaa', 'aaaaaaaaaaaaa')"
csql -u dba testdb -c "insert into del03 values ('bbb', 'bbbbbbbbbbbbb')"
csql -u dba testdb -c "insert into del03 values ('ccc', 'ccccccccccccc')" 

csql -u dba testdb -c "select count(*) from del03"

csql -u dba testdb -c "delete from del03"

csql -u dba testdb -c "select count(*) from del03"
