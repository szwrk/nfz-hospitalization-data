CONNECT c##jsmith/oracle@192.168.0.51:1521/datamart;
ALTER SESSION SET current_schema = dm_nfzhosp;

CREATE TABLE dm_nfzhosp.hospitalizacje_csv(
  rok NUMBER(4, 0) 
, miesiac NUMBER(4, 0) 
, ow_nfz NUMBER(4, 0) 
, nip_podmiotu NUMBER(38, 0) 
, kod_produktu_kontraktowego VARCHAR2(26 BYTE) 
, kod_produktu_jednostkowego VARCHAR2(26 BYTE) 
, kod_trybu_przyjecia NUMBER(38, 0) 
, kod_trybu_wypisu NUMBER(38, 0) 
, plec_pacjenta VARCHAR2(4 BYTE) 
, grupa_wiekowa_pacjenta VARCHAR2(26 BYTE) 
, przedzial_dlugosci_trwania_hospitalizacji VARCHAR2(26 BYTE) 
, liczba_hospitalizacji VARCHAR2(26 BYTE) 
) 
LOGGING 
TABLESPACE tbs_datamart 
;

COMMENT ON TABLE hospitalizacje_csv
IS 'CSV raw data from public source hospitalization jgp 2019-2021 + 2022 - data.gov.pl)'
;

CREATE VIEW trnsltd_hospitalizations AS (
   SELECT
      rok YEAR
      ,miesiac MONTH
      ,ow_nfz department_code
      ,nip_podmiotu nip_code
      ,kod_produktu_kontraktowego contract_code
      ,kod_produktu_jednostkowego service_code
      ,kod_trybu_przyjecia admission_code
      ,kod_trybu_wypisu discharge_code
      ,plec_pacjenta patient_gender
      ,grupa_wiekowa_pacjenta age_category
      ,przedzial_dlugosci_trwania_hospitalizacji hosp_length_in_day_category
      ,liczba_hospitalizacji hospitalization_count
   FROM dm_nfzhosp.hospitalizacje_csv
   ) 
;
   
CREATE SYNONYM hospitalizations FOR dm_nfzhosp.trnsltd_hospitalizations;   

/*Dimension - static */
--Dimension NFZ Departements Regions - static
CREATE TABLE dm_nfzhosp.dim_departments AS 
WITH w_nfz_dept_dict(id_department, region_name, nfz_abbr) AS (
   SELECT 1 ,'Dolnośląski' , 'DŚ' UNION ALL
   SELECT 2, 'Kujawsko-Pomorski', 'KP'  UNION ALL
   SELECT 3, 'Lubelski', 'LB'  UNION ALL
   SELECT 4, 'Lubuski', 'LS'  UNION ALL
   SELECT 5, 'Łódzki', 'ŁD'  UNION ALL
   SELECT 6, 'Małopolski', 'MP'  UNION ALL
   SELECT 7, 'Mazowiecki', 'MZ'  UNION ALL
   SELECT 8, 'Opolski', 'OP'  UNION ALL
   SELECT 9, 'Podkarpacki', 'PK'  UNION ALL
   SELECT 10, 'Podlaski', 'PL'  UNION ALL
   SELECT 11, 'Pomorski', 'PM'  UNION ALL
   SELECT 12, 'Śląski', 'ŚL'  UNION ALL
   SELECT 13, 'Świętokrzyski', 'ŚK'  UNION ALL
   SELECT 14, 'Warmińsko-Mazurski', 'WM'  UNION ALL
   SELECT 15, 'Wielkopolski', 'WP' UNION ALL    
   SELECT 16, 'Zachodniopomorski','ZP'
   )
   SELECT 
      id_department
      ,region_name
      ,nfz_abbr
   FROM w_nfz_dept_dict
;

--Dimension NFZ Dictionaries - static
CREATE TABLE dm_nfzhosp.dim_nfzdicts AS 
WITH w_discharge_mode_dict(id_position, value) AS (
   SELECT 1,'zakończenie procesu terapeutycznego lub diagnostycznego' UNION ALL
   SELECT 2,'skierowanie do dalszego leczenia w lecznictwie ambulatoryjnym' UNION ALL
   SELECT 3,'skierowanie do dalszego leczenia w innym szpitalu' UNION ALL
   SELECT 4,'skierowanie do dalszego leczenia w innym niż szpital, zakładzie opieki stacjonarnej' UNION ALL
   SELECT 6,'wypisanie na własne żądanie' UNION ALL
   SELECT 7,'osoba leczona samowolnie opuściła zakład opieki stacjonarnej przed zakończeniem procesu terapeutycznego lub diagnostycznego' UNION ALL
   SELECT 8,'wypisanie na podstawie art. 22 ust. 1 pkt 3 ustawy o zakładach opieki zdrowotnej' UNION ALL
   SELECT 9,'zgon pacjenta' UNION ALL
   SELECT 10 ,'osoba leczona, przyjęta w trybie oznaczonym kodem "9" lub "10", która samowolnie opuściła podmiot leczniczy' UNION ALL
   SELECT 11 ,'wypisanie na podstawie art. 46 albo 47 ustawy z dnia 22 listopada 2013 r.'
 )
 ,w_admission_mode_dict(id_position, value) AS (
  SELECT 1, 'Przyjęcie planowe' UNION ALL
  SELECT 2, 'Przyjęcie w trybie nagłym w wyniku przekazania przez zespół ratownictwa medycznego' UNION ALL
  SELECT 3, 'Przyjęcie w trybie nagłym – inne przypadki' UNION ALL
  SELECT 4, 'Przyjęcie w trybie nagłym bez skierowania' UNION ALL
  SELECT 5, 'Przyjęcie noworodka w wyniku porodu w tym szpitalu' UNION ALL
  SELECT 6, 'Przyjęcie planowe na podstawie skierowania' UNION ALL
  SELECT 7, 'Przyjęcie planowe osoby, która skorzystała ze świadczeń opieki zdrowotnej poza kolejnością, zgodnie z uprawnieniami przysługującymi jej na podstawie ustawy' UNION ALL
  SELECT 8, 'Przeniesienie z innego szpitala' UNION ALL
  SELECT 9, 'Przyjęcie osoby podlegającej obowiązkowemu leczeniu' UNION ALL
  SELECT 10, 'Przyjęcie przymusowe' UNION ALL
  SELECT 11, 'Przyjęcie na podstawie karty diagnostyki i leczenia onkologicznego'
)
SELECT 'DISM' AS dict_code, D.id_position, D.value FROM w_discharge_mode_dict D
  UNION ALL
SELECT 'ADMM', A.id_position, A.value FROM w_admission_mode_dict A
;

--Dimension Dates - static
CREATE TABLE dm_nfzhosp.dim_date AS
SELECT
  CAST(ROWNUM AS NUMBER(3)) AS id_date
   ,TO_NUMBER(
      to_char(add_months(TO_DATE('2017-01-01','YYYY-MM-DD'), LEVEL -1)
      ,'YYYY')) AS YEAR
   ,TO_NUMBER(
      to_char(add_months(TO_DATE('2017-01-01','YYYY-MM-DD'), LEVEL -1)
      ,'FMMM')) AS MONTH
FROM dual
CONNECT BY LEVEL <= months_between(TO_DATE('2030-01-01','YYYY-MM-DD'),TO_DATE('2017-01-01','YYYY-MM-DD'))
;
/**/
--Dimension NFZ Contracts
CREATE TABLE dm_nfzhosp.dim_contracts (
   id_contract NUMBER(4)
   ,contract_code VARCHAR2(100)
);

--Dimension NFZ Services
CREATE TABLE dm_nfzhosp.dim_services (
    id_service NUMBER(5),
    service_code VARCHAR2(100) -- Adjust the length as per your data
);

--Dimension NFZ Institution
CREATE TABLE dm_nfzhosp.dim_institutions (
    id_institution NUMBER(5),
    nip_code VARCHAR2(100) -- Adjust the length as per your data
);

-- User views
CREATE VIEW dim_nfz_discharges AS SELECT * FROM dm_nfzhosp.dim_nfzdicts D WHERE D.dict_code = 'DISM';
CREATE VIEW dim_nfz_admissions AS SELECT * FROM dm_nfzhosp.dim_nfzdicts D WHERE D.dict_code = 'ADMM';

-- Materialized view for refreshing data
CREATE MATERIALIZED VIEW dm_nfzhosp.mv_hospitalizations AS
SELECT 
  dimdate.id_date dim_date_id
 ,diminst.id_institution dim_institution_id
 ,dimcontr.id_contract AS dim_contract_id
 ,dimdept.id_department dim_department_id
 ,dimserv.id_service dim_service_id
 ,CASE 
   WHEN TRIM(hosp.patient_gender) IN ('1', 'K') THEN 'F'
   WHEN TRIM(hosp.patient_gender) IN ('2', 'M') THEN 'M'
   WHEN TRIM(hosp.patient_gender) IN ('0', '9') THEN '?'
   ELSE '-'
  END patient_gender
 ,REPLACE(hosp.age_category,'65 i więcej','>65') age_category
 ,CASE hosp.hosp_length_in_day_category 
    WHEN  '6 i więcej dni' THEN '>6'
    WHEN '0 dni' THEN '0'
    WHEN '3-5 dni' THEN '3-5'
    WHEN '1-2 dni' THEN '1-2'
   ELSE '-' 
   END AS hosp_length_in_day_category 
FROM trnsltd_hospitalizations hosp
   LEFT JOIN dm_nfzhosp.dim_date dimdate ON dimdate.YEAR = hosp.YEAR AND dimdate.MONTH = hosp.MONTH
   LEFT JOIN dm_nfzhosp.dim_departments dimdept ON dimdept.id_department = hosp.department_code
   LEFT JOIN dm_nfzhosp.dim_contracts dimcontr ON dimcontr.contract_code = hosp.contract_code
   LEFT JOIN dm_nfzhosp.dim_services dimserv ON dimserv.service_code = hosp.service_code
   LEFT JOIN dm_nfzhosp.dim_institutions diminst ON diminst.nip_code = hosp.nip_code
;

COMMENT ON MATERIALIZED VIEW dm_nfzhosp.mv_hospitalizations
IS 'Materialized view transforming hospitalization data from raw CSV dataset.
The new dataset is published once a year on data.gov.pl. You can refresh this view after loading new data into the source table to update the data.
The view is designed to support data analysis and reporting, and it includes denormalization.
Transforms: internationalization, NFZ departments codes, resolving dictionary foreign key codes etc.'
;

--Create facts view for users
CREATE VIEW f_hospitalizations AS 
SELECT *
FROM trnsltd_hospitalizations hosp
;

CONNECT sysdm/oracle@192.168.0.51:1521/datamart;
-- for direct data loading 
GRANT ALL ON dm_nfzhosp.hospitalizacje_csv TO dm_engineer;
GRANT RESOURCE TO dm_engineer;
-- GRANT LOCK TABLE ON dm_nfzhosp.hospitalizacje_csv TO dm_engineer;
-- GRANT DIRECT PATH TO dm_engineer;

-- access users to dedicated layer
GRANT SELECT ON dm_nfzhosp.f_hospitalizations TO dm_analyst;
GRANT SELECT ON dm_nfzhosp.dim_nfz_discharges TO dm_analyst;
GRANT SELECT ON dm_nfzhosp.dim_nfz_admissions TO dm_analyst;
GRANT SELECT ON dm_nfzhosp.dim_date TO dm_analyst;

CONNECT sysdm/oracle@192.168.0.51:1521/datamart;
--Primary keys
ALTER TABLE dm_nfzhosp.dim_departments ADD CONSTRAINT pk_dim_departments PRIMARY KEY (id_department);
ALTER TABLE dm_nfzhosp.dim_nfzdicts ADD CONSTRAINT pk_dim_nfzdicts PRIMARY KEY (dict_code, id_position);
ALTER TABLE dm_nfzhosp.dim_date ADD CONSTRAINT pk_dim_date PRIMARY KEY (id_date);
ALTER TABLE dm_nfzhosp.dim_contracts ADD CONSTRAINT pk_dim_contracts PRIMARY KEY (id_contract);
ALTER TABLE dm_nfzhosp.dim_services ADD CONSTRAINT pk_dim_services PRIMARY KEY (id_service);
ALTER TABLE dm_nfzhosp.dim_institutions ADD CONSTRAINT pk_dim_institutions PRIMARY KEY (id_institution);
--Foreign keys
ALTER TABLE dm_nfzhosp.mv_hospitalizations
ADD CONSTRAINT fk_mv_hosp_dim_date
FOREIGN KEY (dim_date_id)
REFERENCES dm_nfzhosp.dim_date(id_date);

ALTER TABLE dm_nfzhosp.mv_hospitalizations
ADD CONSTRAINT fk_mv_hosp_dim_institutions
FOREIGN KEY (dim_institution_id)
REFERENCES dm_nfzhosp.dim_institutions(id_institution);

ALTER TABLE dm_nfzhosp.mv_hospitalizations
ADD CONSTRAINT fk_mv_hosp_dim_contracts
FOREIGN KEY (dim_contract_id)
REFERENCES dm_nfzhosp.dim_contracts(id_contract);

ALTER TABLE dm_nfzhosp.mv_hospitalizations
ADD CONSTRAINT fk_mv_hosp_dim_departments
FOREIGN KEY (dim_department_id)
REFERENCES dm_nfzhosp.dim_departments(id_department);

ALTER TABLE dm_nfzhosp.mv_hospitalizations
ADD CONSTRAINT fk_mv_hosp_dim_services
FOREIGN KEY (dim_service_id)
REFERENCES dm_nfzhosp.dim_services(id_service);

CONNECT c##jsmith/oracle@192.168.0.51:1521/datamart;
-- Test data engineer account
SELECT COUNT(1) AS eng_mview_test
FROM dm_nfzhosp.mv_hospitalizations
;
SELECT COUNT(1) AS eng_fact_test
FROM dm_nfzhosp.f_hospitalizations
;
-- Test analyst account
CONNECT c##jdoe/oracle@192.168.0.51:1521/datamart;
SET SERVEROUTPUT ON
SELECT COUNT(1) AS analyst_connection_test
FROM dm_nfzhosp.f_hospitalizations

EXIT;

