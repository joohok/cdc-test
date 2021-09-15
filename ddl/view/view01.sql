create table view01 (id int); 
insert into view01  values (100); 
create view view01a as select * from view01; 
alter view view01a as select * from view01 where id=100;
rename view view01a as view01b
drop view01b;  

