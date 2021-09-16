;autocommit off
create table supp19 (a int, b int);
insert into supp19 values (10, 10);
update supp19 set a=100 where b=10;
delete from supp19; 
commit;
