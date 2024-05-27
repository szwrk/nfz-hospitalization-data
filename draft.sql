--1. Copy of source csv "raw" data to new table with cleaning, translations PL -> ENG, processing
CREATE TABLE hospitalizations_2022 AS 
WITH 
 w_hospitalizations_2022 AS (
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
   FROM hospitalizacje_2022
   ) 
 ,w_discharge_mode_dict(id_pos, value) AS (
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
 ),
w_admission_mode_dict(id_pos, value) AS (
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
SELECT 
  hosp.YEAR || '/' || lpad(hosp.MONTH,2,0) as hosp_date_period
 ,dept_dict.nfz_name || ' (' || lpad(hosp.nfz_department_code,2,0) || ')' dept_name_code
 ,hosp.institution_nip_code institution_nip_code
 ,hosp.nfz_service_code nfz_service_code
 ,hosp.nfz_contract_code nfz_contract_code
 ,CASE hosp.patient_gender 
    WHEN 'K' THEN 'M'
    WHEN 'M' THEN 'F'
    ELSE 'unknown'
 END as patient_gender
 ,REPLACE(hosp.age_category,'65 i więcej','>65') age_category
 ,CASE hosp.hosp_length_in_day_category 
    WHEN '6 i więcej dni' THEN '>6'
    WHEN '0 dni' THEN '0'
    WHEN '3-5 dni' THEN '3-5'
    WHEN '1-2 dni' THEN '1-2'
   ELSE 'unknown' 
   END AS hosp_length_in_day_category 
 ,hosp.discharge_code discharge_code
 ,concat(discharge.value,' (', hosp.discharge_code, ')') discharge_mode
 ,hosp.admission_code admission_code
 ,concat(admission.value, ' (', hosp.admission_code,')') admission_mode 
FROM w_hospitalizations_2022 hosp
 LEFT JOIN w_discharge_mode_dict discharge ON hosp.discharge_code = discharge.id_pos
 LEFT JOIN w_admission_mode_dict admission ON hosp.admission_code = admission.id_pos
 LEFT JOIN (
    SELECT id_nfz, nfz_name   
    FROM (
        VALUES
            (1, 'Dolnośląski'),
            (2, 'Kujawsko-Pomorski'),
            (3, 'Lubelski'),
            (4, 'Lubuski'),
            (5, 'Łódzki'),
            (6, 'Małopolski'),
            (7, 'Mazowiecki'),
            (8, 'Opolski'),
            (9, 'Podkarpacki'),
            (10, 'Podlaski'),
            (11, 'Pomorski'),
            (12, 'Śląski'),
            (13, 'Świętokrzyski'),
            (14, 'Warmińsko-Mazurski'),
            (15, 'Wielkopolski'),
            (16, 'Zachodniopomorski')
) AS nfz_dept_dict(id_nfz, nfz_name)
) dept_dict ON hosp.nfz_department_code = dept_dict.id_nfz
;
--add some comment to table
COMMENT ON TABLE hospitalizations_2022
IS oracleCopied raw data from source CSV (Hospitalization Data Set Settlements JGP - data.gov.pl) to a new table, performed data cleaning, translated from Polish (PL) to English (ENG), and processed the dataoracle
;
--checks
--source table load from csv file, data.gov.pl
/
SELECT * 
FROM hospitalizacje_2022 
;
/
SELECT * 
FROM v_hospitalizations_2022
/
--list nfz domain w_admission_mode_dict values
SELECT DISTINCT(kod_trybu_przyjecia) 
FROM hospitalizacje_2022
;
/
--list nfz domain w_discharge_mode_dict values
SELECT DISTINCT(kod_trybu_wypisu) 
FROM hospitalizacje_2022
;
/
--list nfz domain w_discharge_mode_dict values,
SELECT DISTINCT(v_w_hospitalizations_2022.age_cat) 
FROM v_w_hospitalizations_2022
;
/
--check age categieries
SELECT DISTINCT(v_w_hospitalizations_2022.hosp_length_in_day_category) 
FROM v_w_hospitalizations_2022
;
--check nulls
SELECT * 
FROM v_w_hospitalizations_2022
WHERE discharge_mode IS NULL OR admission_mode IS NULL
;
/
-- I found mooore data from years 2017-2021 so I will use it
--copy structure
create table hospitalizacje as select * from hospitalizacje_2022 where 1=0
;
ALTER TABLE hospitalizacje
MOVE TABLESPACE DATAGOV_TBS
;
/
--add quta
ALTER DATABASE DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/datagov01.dbf'
RESIZE 5G;
ALTER DATABASE DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/datagov01.dbf'
AUTOEXTEND ON NEXT 1280K 
MAXSIZE 5G
;
--2. Analitic query for waterfall chart
CREATE VIEW v_hosps_monthly_diffs
WITH monthly_counts AS (
    SELECT
        HOSP_PERIOD,
        COUNT(1) AS month_count
    FROM
        v_hospitalizations_2022
    GROUP BY
        HOSP_PERIOD
)
SELECT
    HOSP_PERIOD,
    month_count,
    nvl(month_count - LAG(month_count, 1) OVER (ORDER BY HOSP_PERIOD),month_count) AS diff_with_prev_month
FROM
    monthly_counts
ORDER BY
    HOSP_PERIOD;

-- Values feature is not supported with materialized view... so i just use with clause
CREATE TABLE hospitalizations_2022 AS 
WITH 
 w_hospitalizations_2022 AS (
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
   FROM hospitalizacje_2022
   ) 
 ,w_discharge_mode_dict(id_pos, value) AS (
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
,nfz_dept_dict AS (
   SELECT 1 AS id_nfz, 'Dolnośląski' AS nfz_name UNION ALL
   SELECT 2, 'Kujawsko-Pomorski' UNION ALL
   SELECT 3, 'Lubelski' UNION ALL
   SELECT 4, 'Lubuski' UNION ALL
   SELECT 5, 'Łódzki' UNION ALL
   SELECT 6, 'Małopolski' UNION ALL
   SELECT 7, 'Mazowiecki' UNION ALL
   SELECT 8, 'Opolski' UNION ALL
   SELECT 9, 'Podkarpacki' UNION ALL
   SELECT 10, 'Podlaski' UNION ALL
   SELECT 11, 'Pomorski' UNION ALL
   SELECT 12, 'Śląski' UNION ALL
   SELECT 13, 'Świętokrzyski' UNION ALL
   SELECT 14, 'Warmińsko-Mazurski' UNION ALL
   SELECT 15, 'Wielkopolski' UNION ALL
   SELECT 16, 'Zachodniopomorski'
 )
SELECT 
  hosp.YEAR || '/' || lpad(hosp.MONTH,2,0) as hosp_date_period
 ,dept_dict.nfz_name || ' (' || lpad(hosp.nfz_department_code,2,0) || ')' dept_name_code
 ,hosp.institution_nip_code institution_nip_code
 ,hosp.nfz_service_code nfz_service_code
 ,hosp.nfz_contract_code nfz_contract_code
 ,CASE hosp.patient_gender 
    WHEN 'K' THEN 'M'
    WHEN 'M' THEN 'F'
    ELSE 'unknown'
 END as patient_gender
 ,REPLACE(hosp.age_category,'65 i więcej','>65') age_category
 ,CASE hosp.hosp_length_in_day_category 
    WHEN '6 i więcej dni' THEN '>6'
    WHEN '0 dni' THEN '0'
    WHEN '3-5 dni' THEN '3-5'
    WHEN '1-2 dni' THEN '1-2'
   ELSE 'unknown' 
   END AS hosp_length_in_day_category 
 ,hosp.discharge_code discharge_code
 ,concat(discharge.value,' (', hosp.discharge_code, ')') discharge_mode
 ,hosp.admission_code admission_code
 ,concat(admission.value, ' (', hosp.admission_code,')') admission_mode 
FROM w_hospitalizations_2022 hosp
 LEFT JOIN w_discharge_mode_dict discharge ON hosp.discharge_code = discharge.id_pos
 LEFT JOIN w_admission_mode_dict admission ON hosp.admission_code = admission.id_pos
 LEFT JOIN w_discharge_mode_dict discharge ON hosp.discharge_code = discharge.id_pos
 LEFT JOIN w_admission_mode_dict admission ON hosp.admission_code = admission.id_pos
 LEFT JOIN nfz_dept_dict dept_dict ON hosp.nfz_department_code = dept_dict.id_nfz;
;

-- about SQLLoader, u can use direct for faster data loading, way to use 1. add to comment, 2. add parameter to control file, i tried with parall options but its not give me any decrease of execution time... for that simple case
-- add refresh to script
-- add mview statistics to script

-- Table is too large (limit 12 GB in oracle version), so I convert my single analytical table into a classic star schema, extract dictionaries to dimansions, making the hospitalization table a fact table. I also add a layer for analytics users (synonyms, views for mv, privs)
-- institution_nip_code is a candidate for dimension cardinality circa 8k
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
   -- WHERE hosp.year >= 2020
;
/**
Dimension date as surogate vs yyyymmdd?
Human readable vs performance.
Small int vs number.
For my slow server and oracle express limits.. i prefer better optymalizatio
*/
CREATE TABLE DIM_DATE AS
SELECT 
   ROWNUM AS id_date
   ,TO_CHAR(ADD_MONTHS(TO_DATE('2019-01-01','YYYY-MM-DD'), LEVEL)
      ,'YYYY') AS YEAR
   ,TO_CHAR(ADD_MONTHS(TO_DATE('2019-01-01','YYYY-MM-DD'), LEVEL)
      ,'MM') AS MONTH
FROM DUAL
CONNECT BY LEVEL <= MONTHS_BETWEEN(TO_DATE('2030-01-01','YYYY-MM-DD'),TO_DATE('2019-01-01','YYYY-MM-DD')) 
;
ALTER TABLE HOSPITALIZACJE_CSV ADD DATE_ID NUMBER
; 
UPDATE HOSPITALIZACJE_CSV H SET DATE_ID = (SELECT ID FROM DIM_DATE DIM WHERE DIM.YEAR = H.ROK AND DIM.MONTH = H.MIESIAC)
;
drop table dim_date
;
CREATE TABLE DIM_DATE AS
SELECT 
   ROWNUM AS id_date
   ,TO_NUMBER(
      TO_CHAR(ADD_MONTHS(TO_DATE('2017-01-01','YYYY-MM-DD'), LEVEL -1)
      ,'YYYY')) AS YEAR
   ,TO_NUMBER(
      TO_CHAR(ADD_MONTHS(TO_DATE('2017-01-01','YYYY-MM-DD'), LEVEL -1)
      ,'FMMM')) AS MONTH
FROM DUAL
CONNECT BY LEVEL <= MONTHS_BETWEEN(TO_DATE('2030-01-01','YYYY-MM-DD'),TO_DATE('2017-01-01','YYYY-MM-DD')) 
;

ALTER TABLE HOSPITALIZACJE_CSV ADD DATE_ID NUMBER; 

UPDATE HOSPITALIZACJE_CSV H SET DATE_ID = (SELECT ID FROM DIM_DATE DIM WHERE DIM.YEAR = H.ROK AND DIM.MONTH = H.MIESIAC)
;
DESC HOSPITALIZATION_SOURCE;

UPDATE HOSPITALIZACJE_CSV H SET DATE_ID = (SELECT ID FROM DIM_DATE DIM WHERE DIM.YEAR = H.ROK AND DIM.MONTH = H.MIESIAC)
;

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
 (SELECT ID FROM DIM_DATE DIM WHERE DIM.YEAR = hosp.YEAR AND DIM.MONTH = hosp.month)  dim_id
 ,dept_dict.nfz_abbr || ' (' || lpad(hosp.nfz_department_code,2,0) || ')' dept_name_code
 ,hosp.institution_nip_code institution_nip_code
 ,hosp.nfz_service_code nfz_service_code
 ,hosp.nfz_contract_code nfz_contract_code
 ,CASE hosp.patient_gender 
    WHEN 'K' THEN 'F'
    WHEN 'M' THEN 'M'
    ELSE hosp.patient_gender 
 END as patient_gender
 ,REPLACE(hosp.age_category,'65 i wiecej','>65') age_category
 ,CASE substr(hosp.hosp_length_in_day_category,0,1)
    WHEN '6' THEN '>6'
    WHEN '0' THEN '0'
    WHEN '3' THEN '3-5'
    WHEN '1' THEN '1-2'
   ELSE hosp.hosp_length_in_day_category
   END AS hosp_length_in_day_category 
FROM w_hospitalizations hosp
   LEFT JOIN w_nfz_dept_dict dept_dict ON hosp.nfz_department_code = dept_dict.id_nfz
;
select * from DIM_DATE;


SELECT value FROM nls_database_parameters WHERE parameter = 'NLS_CHARACTERSET';