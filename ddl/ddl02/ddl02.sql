#!/bin/bash 

count=${1}

csql -u dba ddl02db -c "CREATE TABLE c_tbl (id INT NOT NULL DEFAULT 0 PRIMARY KEY,phone VARCHAR(10));
    INSERT INTO c_tbl VALUES (1,'111-1111'), (2,'222-2222'), (3, '333-3333');
    INSERT INTO c_tbl VALUES (4,'444-1111'), (5,'555-2222'), (6, '666-3333');
    DELETE FROM c_tbl;"

csql -u dba ddl02db -c "alter TABLE c_tbl add column c int ;"
