-- CONNECT sys/oracle@192.168.0.51:1521/free AS SYSDBA;
ALTER SESSION SET CONTAINER = CDB$ROOT;
/* Drop objects */

drop user c##jsmith cascade;
drop user c##jdoe cascade;

ALTER SESSION SET CONTAINER = datamart;

drop materialized view dm_nfzhosp.mv_hospitalizations;
drop table dm_nfzhosp.hospitalizacje_csv;
drop table dm_nfzhosp.nfz_dicts;
drop table dm_nfzhosp.dim_nfz_dept;

drop synonym dm_nfzhosp.hospitalization_source;
drop user dm_nfzhosp cascade;
drop user sysdm;

drop role dm_engineer;
drop role dm_analyst;

drop tablespace tbs_datamart including contents and datafiles;
drop tablespace tbs_datamart_idx including contents and datafiles;
drop tablespace tbs_devdata including contents and datafiles;

/* Drop DB */
-- CONNECT sys/oracle@192.168.0.51:1521/free AS SYSDBA;
-- ALTER SESSION SET CONTAINER = CDB$ROOT;
-- ALTER PLUGGABLE DATABASE DATAMART CLOSE;
-- DROP PLUGGABLE DATABASE datamart INCLUDING DATAFILES;

exit;