csql -u dba api05db -c " CREATE USER joo GROUPS dba"

csql -u dba api05db -c "drop table if exists api04a"
csql -u joo api05db -c "drop table if exists api04b"
csql -u dba api05db -c "drop table if exists api04c"

sleep 1
csql -u public api05db -c "create table api04a (a int)"
csql -u joo api05db -c "create table api04b (a int)"
csql -u dba api05db -c "create table api04c (a int)"
