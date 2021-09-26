csql -u dba api14db -c "drop table if exists api14a "
csql -u dba api14db -c "drop table if exists api14b "
csql -u dba api14db -c "drop table if exists api14c "
sleep 1

csql -u dba api14db -c "create table api14a (a int)"
csql -u dba api14db -c "create table api14b (a int)"
csql -u dba api14db -c "create table api14c (a int)"
