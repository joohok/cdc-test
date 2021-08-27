#!/bin/bash 

count=${1}

csql -u dba testdb -c "CREATE TABLE const_tbl1(id INT NOT NULL, INDEX i_index(id ASC), phone VARCHAR);";

csql -u dba testdb -c "CREATE TABLE const_tbl7 (id INT NOT NULL,phone VARCHAR, CONSTRAINT pk_id PRIMARY KEY (id));"

csql -u dba testdb -c "CREATE TABLE a_tbl (
    id INT NOT NULL DEFAULT 0 PRIMARY KEY,
      phone VARCHAR(10)
    );
    INSERT INTO a_tbl VALUES (1,'111-1111'), (2,'222-2222'), (3, '333-3333');"

csql -u dba testdb -c "CREATE TABLE new_tbl2 (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, phone VARCHAR) AS SELECT * FROM const_tbl7;"

csql -u dba testdb -c "
CREATE TABLE b_tbl;
ALTER TABLE b_tbl ADD COLUMN age INT DEFAULT 0 NOT NULL COMMENT 'age comment';
ALTER TABLE b_tbl ADD COLUMN name VARCHAR FIRST;
ALTER TABLE b_tbl ADD COLUMN id INT NOT NULL AUTO_INCREMENT UNIQUE FIRST;
ALTER TABLE b_tbl ADD COLUMN phone VARCHAR(13) DEFAULT '000-0000-0000' AFTER name;
ALTER TABLE b_tbl ADD COLUMN birthday VARCHAR(20) DEFAULT TO_CHAR(SYSDATE,'YYYY-MM-DD');
CREATE TABLE t1(id1 VARCHAR(20), id2 VARCHAR(20) DEFAULT '');
ALTER TABLE t1 ALTER COLUMN id1 SET DEFAULT TO_CHAR(SYS_DATETIME, 'yyyy/mm/dd hh:mi:ss');"
