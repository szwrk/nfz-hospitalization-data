-- CONNECT sys/oracle@192.168.0.51:1521/free AS SYSDBA;
ALTER SESSION SET CONTAINER = cdb$root;

/* Drop objects */
DROP USER c##jsmith CASCADE;
DROP USER c##jdoe CASCADE;

ALTER SESSION SET CONTAINER = datamart;

 -- DROP MATERIALIZED VIEW dm_nfzhosp.mv_hospitalizations;
 -- DROP TABLE dm_nfzhosp.hospitalizacje_csv;
 -- DROP TABLE dm_nfzhosp.nfz_dicts;

 -- DROP TABLE dm_nfzhosp.dim_contracts;
 -- DROP TABLE dm_nfzhosp.dim_services;
 -- DROP TABLE dm_nfzhosp.dim_departments;

 -- DROP VIEW dm_nfzhosp.trnsltd_hospitalizations;
 -- DROP SYNONYM dm_nfzhosp.hospitalizations_source;

DROP USER dm_nfzhosp CASCADE;
DROP USER sysdm;

DROP ROLE dm_engineer;
DROP ROLE dm_analyst;

DROP TABLESPACE tbs_datamart INCLUDING CONTENTS AND DATAFILES;
DROP TABLESPACE tbs_datamart_idx INCLUDING CONTENTS AND DATAFILES;
DROP TABLESPACE tbs_devdata INCLUDING CONTENTS AND DATAFILES;

/* Drop DB */
ALTER SESSION SET CONTAINER = cdb$root;
ALTER PLUGGABLE DATABASE pdb$seed OPEN READ ONLY;

ALTER PLUGGABLE DATABASE datamart CLOSE;
DROP PLUGGABLE DATABASE datamart INCLUDING DATAFILES;

EXIT;