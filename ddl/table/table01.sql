rename table table01 as table01a; 
alter table table01a add column b int ; 
insert into table01a values (10, 10); 
truncate table01a; 
drop table table01a; 
