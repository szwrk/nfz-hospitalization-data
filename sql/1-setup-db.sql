/* Create DB */
-- CREATE PLUGGABLE DATABASE datamart
-- FILE_NAME_CONVERT = ('/opt/oracle/oradata/FREE/', '/opt/oracle/oradata/FREE/DATAMART/
-- ALTER PLUGGABLE DATABASE datamart OPEN;

-- Setup datamart root...
ALTER SESSION SET CONTAINER = datamart;
CREATE USER sysdm IDENTIFIED BY oracle;
GRANT dba TO sysdm;

/* Tablespaces */
-- Creating tablespaces...
CONNECT sysdm/oracle@192.168.0.51:1521/datamart;
ALTER SESSION SET CONTAINER = datamart;

CREATE SMALLFILE TABLESPACE tbs_devdata 
DATAFILE '/opt/oracle/oradata/FREE/DATAMART/tbs_devdata01.dbf' 
SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 1G;

CREATE SMALLFILE TABLESPACE tbs_datamart 
DATAFILE '/opt/oracle/oradata/FREE/DATAMART/tbs_datamart01.dbf' 
SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 10G;

CREATE SMALLFILE TABLESPACE tbs_datamart_idx 
DATAFILE '/opt/oracle/oradata/FREE/DATAMART/tbs_datamart_idx01.dbf' 
SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 5G;

CREATE USER dm_nfzhosp
IDENTIFIED BY oracle
DEFAULT TABLESPACE tbs_datamart
QUOTA 5500M ON tbs_datamart;

/* Create common user and roles */
-- Setup common users...
CONNECT SYS/oracle@192.168.0.51:1521/free AS SYSDBA;
CREATE USER c##jsmith IDENTIFIED BY oracle;
CREATE USER c##jdoe IDENTIFIED BY oracle;

ALTER SESSION SET CONTAINER = datamart;

CREATE ROLE dm_engineer;
CREATE ROLE dm_analyst;

--tech datamart schema
GRANT CONNECT TO dm_nfzhosp; 
GRANT CREATE TABLE TO dm_nfzhosp; -- MV need it
GRANT CREATE MATERIALIZED view to dm_nfzhosp;

--setup data engineer
GRANT CONNECT TO dm_engineer;
GRANT CREATE ANY TABLE TO dm_engineer;
GRANT CREATE ANY VIEW TO dm_engineer;
GRANT CREATE ANY MATERIALIZED VIEW TO dm_engineer;
GRANT ALTER SESSION TO dm_engineer;

GRANT SELECT ANY TABLE TO dm_engineer;
GRANT SELECT ANY TABLE TO dm_engineer;
GRANT INSERT ANY TABLE TO dm_engineer;
GRANT UPDATE ANY TABLE TO dm_engineer;
GRANT DELETE ANY TABLE TO dm_engineer;
GRANT COMMENT ANY TABLE TO dm_engineer;
-- GRANT COMMENT ANY MATERIALIZED VIEW TO dm_engineer;

--setup data analyst
GRANT CONNECT TO dm_analyst;

-- add roles
GRANT dm_engineer TO c##jsmith;
GRANT dm_analyst TO c##jdoe;

ALTER USER c##jsmith DEFAULT ROLE dm_engineer;
ALTER USER c##jdoe DEFAULT ROLE dm_analyst;

ALTER USER c##jsmith QUOTA 5500M ON tbs_devdata;
ALTER USER c##jsmith QUOTA 5500M ON tbs_datamart;

EXIT;
