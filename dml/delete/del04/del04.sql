#!/bin/bash 

count=${1}

csql -u dba testdb -c 'drop table if exists del04;'
sleep 1;

csql -u dba testdb -c 'create table del04 (content CLOB, image BLOB);'

csql -u dba testdb -c "insert into del04 values (CHAR_TO_CLOB('aaa'), BIT_TO_BLOB(X'000001'))"
csql -u dba testdb -c "insert into del04 values (CHAR_TO_CLOB('bbb'), BIT_TO_BLOB(X'000011'))"
csql -u dba testdb -c "insert into del04 values (CHAR_TO_CLOB('ccc'), BIT_TO_BLOB(X'000111'))"

csql -u dba testdb -c "select * from del04"

csql -u dba testdb -c "delete from del04"

csql -u dba testdb -c "select * from del04"
