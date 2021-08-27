csql -u dba testdb -c " CREATE USER joo GROUPS dba"

csql -u dba testdb -c "drop table if exists api04a"
csql -u joo testdb -c "drop table if exists api04b"
csql -u dba testdb -c "drop table if exists api04c"

sleep 1
csql -u public testdb -c "create table api04a (a int)"
csql -u joo testdb -c "create table api04b (a int)"
csql -u dba testdb -c "create table api04c (a int)"
