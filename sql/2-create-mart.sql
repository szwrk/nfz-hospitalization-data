CONNECT c##jsmith/oracle@192.168.0.51:1521/datamart;
ALTER SESSION SET CURRENT_SCHEMA = dm_nfzhosp;

CREATE TABLE dm_nfzhosp.hospitalizacje_csv(
  rok NUMBER(38, 0) 
, miesiac NUMBER(38, 0) 
, ow_nfz NUMBER(38, 0) 
, nip_podmiotu NUMBER(38, 0) 
, kod_produktu_kontraktowego VARCHAR2(26 BYTE) 
, kod_produktu_jednostkowego VARCHAR2(26 BYTE) 
, kod_trybu_przyjecia NUMBER(38, 0) 
, kod_trybu_wypisu NUMBER(38, 0) 
, plec_pacjenta VARCHAR2(26 BYTE) 
, grupa_wiekowa_pacjenta VARCHAR2(26 BYTE) 
, przedzial_dlugosci_trwania_hospitalizacji VARCHAR2(26 BYTE) 
, liczba_hospitalizacji VARCHAR2(26 BYTE) 
) 
LOGGING 
TABLESPACE tbs_datamart 
;

-- View for users
CREATE VIEW dm_nfzhosp.mv_hospitalizations AS
(SELECT * FROM dm_nfzhosp.hospitalizacje_csv);

CONNECT sysdm/oracle@192.168.0.51:1521/datamart;
GRANT SELECT ON dm_nfzhosp.mv_hospitalizations TO dm_analyst;

--test data engineer account
CONNECT c##jsmith/oracle@192.168.0.51:1521/datamart;
select count(1) as engineer_connection_test
from dm_nfzhosp.mv_hospitalizations;

--test analyst account
CONNECT c##jdoe/oracle@192.168.0.51:1521/datamart;
select count(1) as analyst_connection_test
from dm_nfzhosp.mv_hospitalizations;

exit;

