CONNECT c##jsmith/oracle@192.168.0.51:1521/datamart;
ALTER SESSION SET current_schema = dm_nfzhosp;

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
COMMENT ON TABLE hospitalizacje_csv
IS 'CSV raw data from public source hospitalization jgp 2019-2021 + 2022 - data.gov.pl)'
;

CREATE SYNONYM hospitalization_source FOR dm_nfzhosp.hospitalizacje_csv;

CREATE TABLE dm_nfzhosp.nfz_dicts AS 
WITH w_discharge_mode_dict(id_pos, value) AS (
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
 ,w_admission_mode_dict(id_pos, value) AS (
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
SELECT 'DISM' as dict_code, d.id_pos, d.value FROM w_discharge_mode_dict d
  UNION ALL
SELECT 'ADMM', a.id_pos, a.value FROM w_admission_mode_dict a
;

CREATE VIEW dim_nfz_discharges as select * from dm_nfzhosp.nfz_dicts d where d.dict_code = 'DISM';
CREATE VIEW dim_nfz_admissions as select * from dm_nfzhosp.nfz_dicts d where d.dict_code = 'ADMM';

-- Materialized view for refreshing data
CREATE MATERIALIZED VIEW dm_nfzhosp.mv_hospitalizations AS
WITH 
 w_hospitalizations AS (
   SELECT
      rok YEAR
      ,miesiac MONTH
      ,ow_nfz nfz_department_code
      ,nip_podmiotu institution_nip_code
      ,kod_produktu_kontraktowego nfz_contract_code
      ,kod_produktu_jednostkowego nfz_service_code
      ,kod_trybu_przyjecia admission_code
      ,kod_trybu_wypisu discharge_code
      ,plec_pacjenta patient_gender
      ,grupa_wiekowa_pacjenta age_category
      ,przedzial_dlugosci_trwania_hospitalizacji hosp_length_in_day_category
      ,liczba_hospitalizacji hospitalization_count
   FROM dm_nfzhosp.hospitalization_source
   ) 
, w_nfz_dept_dict(id_nfz, region_name, nfz_abbr) AS (
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
   SELECT 15, 'Wielkopolski', 'WP'  UNION ALL
   SELECT 16, 'Zachodniopomorski', 'ZP' 
)
SELECT 
  hosp.YEAR || '/' || lpad(hosp.MONTH,2,0) as hosp_date_period
 ,dept_dict.nfz_abbr || ' (' || lpad(hosp.nfz_department_code,2,0) || ')' dept_name_code
 ,hosp.institution_nip_code institution_nip_code
 ,hosp.nfz_service_code nfz_service_code
 ,hosp.nfz_contract_code nfz_contract_code
 ,CASE hosp.patient_gender 
    WHEN 'K' THEN 'F'
    WHEN 'M' THEN 'M'
    ELSE '-'
 END as patient_gender
 ,REPLACE(hosp.age_category,'65 i więcej','>65') age_category
 ,CASE hosp.hosp_length_in_day_category 
    WHEN '6 i więcej dni' THEN '>6'
    WHEN '0 dni' THEN '0'
    WHEN '3-5 dni' THEN '3-5'
    WHEN '1-2 dni' THEN '1-2'
   ELSE '-' 
   END AS hosp_length_in_day_category 
FROM w_hospitalizations hosp
   LEFT JOIN w_nfz_dept_dict dept_dict ON hosp.nfz_department_code = dept_dict.id_nfz
;
COMMENT ON MATERIALIZED VIEW dm_nfzhosp.mv_hospitalizations
IS 'Materialized view transforming hospitalization data from raw CSV dataset.
The new dataset is published once a year on data.gov.pl. You can refresh this view after loading new data into the source table to update the data.
The view is designed to support data analysis and reporting, and it includes denormalization.
Transforms: internationalization, NFZ departments codes, resolving dictionary foreign key codes etc.'
;

--Create facts view for users
CREATE VIEW f_hospitalizations as select * from dm_nfzhosp.mv_hospitalizations;

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

-- test data engineer account
CONNECT c##jsmith/oracle@192.168.0.51:1521/datamart;
SELECT COUNT(1) AS eng_onnection_test
FROM dm_nfzhosp.mv_hospitalizations
WHERE 1=0;

SELECT COUNT(1) AS eng_connection_test
FROM dm_nfzhosp.f_hospitalizations
WHERE 1=0;

--test analyst account
CONNECT c##jdoe/oracle@192.168.0.51:1521/datamart;
SET SERVEROUTPUT ON
SELECT COUNT(1) AS analyst_connection_test
FROM dm_nfzhosp.f_hospitalizations
WHERE 1=0;

EXIT;

