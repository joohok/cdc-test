csql -u dba api18db -c " CREATE USER joo GROUPS dba"

csql -u dba api18db -c "drop table if exists api18a"
csql -u joo api18db -c "drop table if exists api18b"
csql -u dba api18db -c "drop table if exists api18c"

sleep 1
csql -u public api18db -c "create table api18a (a int)"
csql -u joo api18db -c "create table api18b (a int)"
csql -u dba api18db -c "create table api18c (a int)"
