csql -u dba api06db -c " drop table if exists api06"
sleep 1
csql -u dba api06db -c " create table api06 (a int not null primary key, b int)"
csql -u dba api06db -c "insert into api06 values (1,2)"
csql -u dba api06db -c "insert into api06 values (3,4)"
csql -u dba api06db -c "insert into api06 values (5,6)"
csql -u dba api06db -c "insert into api06 values (7,8)"
csql -u dba api06db -c "delete from api06"
