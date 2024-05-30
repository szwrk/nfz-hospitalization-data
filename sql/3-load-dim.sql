CONNECT c##jsmith/oracle@192.168.0.51:1521/datamart;
ALTER SESSION SET current_schema = dm_nfzhosp;

INSERT INTO dm_nfzhosp.dim_institutions (id_institution, nip_code)
SELECT 
    ROWNUM AS id_institution,
    nip_code
FROM (
    SELECT DISTINCT nip_code
    FROM dm_nfzhosp.TRNSLTD_HOSPITALIZATIONS
) sq;

INSERT INTO dm_nfzhosp.dim_services (id_service, service_code)
SELECT 
    ROWNUM AS id_service,
    service_code
FROM (
    SELECT DISTINCT service_code
    FROM dm_nfzhosp.TRNSLTD_HOSPITALIZATIONS
) sq;

INSERT INTO dm_nfzhosp.dim_contracts
SELECT 
   -- CAST(ROWNUM AS NUMBER(4)) AS id_contract
   ROWNUM AS id_contract
   ,sq.contract_code
FROM (
   SELECT contract_code FROM (SELECT DISTINCT (contract_code) AS contract_code FROM dm_nfzhosp.TRNSLTD_HOSPITALIZATIONS)
   ) sq
;
EXIT;

