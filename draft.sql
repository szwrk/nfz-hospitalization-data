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
    ELECT id_nfz, nfz_name   
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
) AS nfz_dept_dict(id_nfz, nfz_name);
) dept_dict ON hosp.nfz_department_code = dept_dict.id_nfz
;
--add some comment to table
COMMENT ON TABLE hospitalizations_2022
IS "Copied raw data from source CSV (Hospitalization Data Set Settlements JGP - data.gov.pl) to a new table, performed data cleaning, translated from Polish (PL) to English (ENG), and processed the data"
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