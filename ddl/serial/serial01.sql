create serial serial01;
alter serial serial01 start with 10;
select serial_next_value(serial01, 10);
insert into serial01a values (NULL);
drop serial serial01; 
