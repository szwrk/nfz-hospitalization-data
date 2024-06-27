--1. Copy of source csv "raw" data to new table with cleaning, translations PL -> ENG, processing
create table hospitalizations_2022 as 
with 
 w_hospitalizations_2022 as (
   select
      rok year
      ,miesiac month
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
   from hospitalizacje_2022
   ) 
 ,w_discharge_mode_dict(id_pos, value) as (
   select 1,zakończenie procesu terapeutycznego lub diagnostycznego union all
   select 2,skierowanie do dalszego leczenia w lecznictwie ambulatoryjnym union all
   select 3,skierowanie do dalszego leczenia w innym szpitalu union all
   select 4,skierowanie do dalszego leczenia w innym niż szpital, zakładzie opieki stacjonarnej union all
   select 6,wypisanie na własne żądanie union all
   select 7,osoba leczona samowolnie opuściła zakład opieki stacjonarnej przed zakończeniem procesu terapeutycznego lub diagnostycznego union all
   select 8,wypisanie na podstawie art. 22 ust. 1 pkt 3 ustawy o zakładach opieki zdrowotnej union all
   select 9,zgon pacjenta union all
   select 10 ,osoba leczona, przyjęta w trybie oznaczonym kodem "9" lub "10", która samowolnie opuściła podmiot leczniczy union all
   select 11 ,wypisanie na podstawie art. 46 albo 47 ustawy z dnia 22 listopada 2013 r.
 ),
w_admission_mode_dict(id_pos, value) as (
  select 1, Przyjęcie planowe union all
  select 2, Przyjęcie w trybie nagłym w wyniku przekazania przez zespół ratownictwa medycznego union all
  select 3, Przyjęcie w trybie nagłym – inne przypadki union all
  select 4, Przyjęcie w trybie nagłym bez skierowania union all
  select 5, Przyjęcie noworodka w wyniku porodu w tym szpitalu union all
  select 6, Przyjęcie planowe na podstawie skierowania union all
  select 7, Przyjęcie planowe osoby, która skorzystała ze świadczeń opieki zdrowotnej poza kolejnością, zgodnie z uprawnieniami przysługującymi jej na podstawie ustawy union all
  select 8, Przeniesienie z innego szpitala union all
  select 9, Przyjęcie osoby podlegającej obowiązkowemu leczeniu union all
  select 10, Przyjęcie przymusowe union all
  select 11, Przyjęcie na podstawie karty diagnostyki i leczenia onkologicznego
)
select 
  hosp.year || / || lpad(hosp.month,2,0) as hosp_date_period
 ,dept_dict.nfz_name ||  ( || lpad(hosp.nfz_department_code,2,0) || ) dept_name_code
 ,hosp.institution_nip_code institution_nip_code
 ,hosp.nfz_service_code nfz_service_code
 ,hosp.nfz_contract_code nfz_contract_code
 ,case hosp.patient_gender 
    when K then M
    when M then F
    else unknown
 end as patient_gender
 ,replace(hosp.age_category,65 i więcej,>65) age_category
 ,case hosp.hosp_length_in_day_category 
    when 6 i więcej dni then >6
    when 0 dni then 0
    when 3-5 dni then 3-5
    when 1-2 dni then 1-2
   else unknown 
   end as hosp_length_in_day_category 
 ,hosp.discharge_code discharge_code
 ,concat(discharge.value, (, hosp.discharge_code, )) discharge_mode
 ,hosp.admission_code admission_code
 ,concat(admission.value,  (, hosp.admission_code,)) admission_mode 
from w_hospitalizations_2022 hosp
 left join w_discharge_mode_dict discharge on hosp.discharge_code = discharge.id_pos
 left join w_admission_mode_dict admission on hosp.admission_code = admission.id_pos
 left join (
    select id_nfz, nfz_name   
    from (
        values
            (1, Dolnośląski),
            (2, Kujawsko-Pomorski),
            (3, Lubelski),
            (4, Lubuski),
            (5, Łódzki),
            (6, Małopolski),
            (7, Mazowiecki),
            (8, Opolski),
            (9, Podkarpacki),
            (10, Podlaski),
            (11, Pomorski),
            (12, Śląski),
            (13, Świętokrzyski),
            (14, Warmińsko-Mazurski),
            (15, Wielkopolski),
            (16, Zachodniopomorski)
) as nfz_dept_dict(id_nfz, nfz_name)
) dept_dict on hosp.nfz_department_code = dept_dict.id_nfz
;
--add some comment to table
comment on table hospitalizations_2022
is oraclecopied raw data from source csv (hospitalization data set settlements jgp - data.gov.pl) to a new table, performed data cleaning, translated from polish (pl) to english (eng), and processed the dataoracle
;
--checks
--source table load from csv file, data.gov.pl
/
select * 
from hospitalizacje_2022 
;
/
select * 
from v_hospitalizations_2022
/
--list nfz domain w_admission_mode_dict values
select distinct(kod_trybu_przyjecia) 
from hospitalizacje_2022
;
/
--list nfz domain w_discharge_mode_dict values
select distinct(kod_trybu_wypisu) 
from hospitalizacje_2022
;
/
--list nfz domain w_discharge_mode_dict values,
select distinct(v_w_hospitalizations_2022.age_cat) 
from v_w_hospitalizations_2022
;
/
--check age categieries
select distinct(v_w_hospitalizations_2022.hosp_length_in_day_category) 
from v_w_hospitalizations_2022
;
--check nulls
select * 
from v_w_hospitalizations_2022
where discharge_mode is null or admission_mode is null
;
/
-- I found mooore data from years 2017-2021 so I will use it
--copy structure
create table hospitalizacje as select * from hospitalizacje_2022 where 1=0
;
alter table hospitalizacje
move tablespace datagov_tbs
;
/
--add quta
alter database datafile /opt/oracle/oradata/FREE/FREEPDB1/datagov01.dbf
resize 5G;
alter database datafile /opt/oracle/oradata/FREE/FREEPDB1/datagov01.dbf
autoextend on next 1280K 
maxsize 5G
;
--2. Analitic query for waterfall chart
create view v_hosps_monthly_diffs
with monthly_counts as (
    select
        hosp_period,
        count(1) as month_count
    from
        v_hospitalizations_2022
    group by
        hosp_period
)
select
    hosp_period,
    month_count,
    nvl(month_count - lag(month_count, 1) over (order by hosp_period),month_count) as diff_with_prev_month
from
    monthly_counts
order by
    hosp_period;

-- Values feature is not supported with materialized view... so i just use with clause
create table hospitalizations_2022 as 
with 
 w_hospitalizations_2022 as (
   select
      rok year
      ,miesiac month
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
   from hospitalizacje_2022
   ) 
 ,w_discharge_mode_dict(id_pos, value) as (
   select 1,zakończenie procesu terapeutycznego lub diagnostycznego union all
   select 2,skierowanie do dalszego leczenia w lecznictwie ambulatoryjnym union all
   select 3,skierowanie do dalszego leczenia w innym szpitalu union all
   select 4,skierowanie do dalszego leczenia w innym niż szpital, zakładzie opieki stacjonarnej union all
   select 6,wypisanie na własne żądanie union all
   select 7,osoba leczona samowolnie opuściła zakład opieki stacjonarnej przed zakończeniem procesu terapeutycznego lub diagnostycznego union all
   select 8,wypisanie na podstawie art. 22 ust. 1 pkt 3 ustawy o zakładach opieki zdrowotnej union all
   select 9,zgon pacjenta union all
   select 10 ,osoba leczona, przyjęta w trybie oznaczonym kodem "9" lub "10", która samowolnie opuściła podmiot leczniczy union all
   select 11 ,wypisanie na podstawie art. 46 albo 47 ustawy z dnia 22 listopada 2013 r.
 )
 ,w_admission_mode_dict(id_pos, value) as (
  select 1, Przyjęcie planowe union all
  select 2, Przyjęcie w trybie nagłym w wyniku przekazania przez zespół ratownictwa medycznego union all
  select 3, Przyjęcie w trybie nagłym – inne przypadki union all
  select 4, Przyjęcie w trybie nagłym bez skierowania union all
  select 5, Przyjęcie noworodka w wyniku porodu w tym szpitalu union all
  select 6, Przyjęcie planowe na podstawie skierowania union all
  select 7, Przyjęcie planowe osoby, która skorzystała ze świadczeń opieki zdrowotnej poza kolejnością, zgodnie z uprawnieniami przysługującymi jej na podstawie ustawy union all
  select 8, Przeniesienie z innego szpitala union all
  select 9, Przyjęcie osoby podlegającej obowiązkowemu leczeniu union all
  select 10, Przyjęcie przymusowe union all
  select 11, Przyjęcie na podstawie karty diagnostyki i leczenia onkologicznego
)
,nfz_dept_dict as (
   select 1 as id_nfz, Dolnośląski as nfz_name union all
   select 2, Kujawsko-Pomorski union all
   select 3, Lubelski union all
   select 4, Lubuski union all
   select 5, Łódzki union all
   select 6, Małopolski union all
   select 7, Mazowiecki union all
   select 8, Opolski union all
   select 9, Podkarpacki union all
   select 10, Podlaski union all
   select 11, Pomorski union all
   select 12, Śląski union all
   select 13, Świętokrzyski union all
   select 14, Warmińsko-Mazurski union all
   select 15, Wielkopolski union all
   select 16, Zachodniopomorski
 )
select 
  hosp.year || / || lpad(hosp.month,2,0) as hosp_date_period
 ,dept_dict.nfz_name ||  ( || lpad(hosp.nfz_department_code,2,0) || ) dept_name_code
 ,hosp.institution_nip_code institution_nip_code
 ,hosp.nfz_service_code nfz_service_code
 ,hosp.nfz_contract_code nfz_contract_code
 ,case hosp.patient_gender 
    when K then M
    when M then F
    else unknown
 end as patient_gender
 ,replace(hosp.age_category,65 i więcej,>65) age_category
 ,case hosp.hosp_length_in_day_category 
    when 6 i więcej dni then >6
    when 0 dni then 0
    when 3-5 dni then 3-5
    when 1-2 dni then 1-2
   else unknown 
   end as hosp_length_in_day_category 
 ,hosp.discharge_code discharge_code
 ,concat(discharge.value, (, hosp.discharge_code, )) discharge_mode
 ,hosp.admission_code admission_code
 ,concat(admission.value,  (, hosp.admission_code,)) admission_mode 
from w_hospitalizations_2022 hosp
 left join w_discharge_mode_dict discharge on hosp.discharge_code = discharge.id_pos
 left join w_admission_mode_dict admission on hosp.admission_code = admission.id_pos
 left join w_discharge_mode_dict discharge on hosp.discharge_code = discharge.id_pos
 left join w_admission_mode_dict admission on hosp.admission_code = admission.id_pos
 left join nfz_dept_dict dept_dict on hosp.nfz_department_code = dept_dict.id_nfz;
;

-- about SQLLoader, u can use direct for faster data loading, way to use 1. add to comment, 2. add parameter to control file, i tried with parall options but its not give me any decrease of execution time... for that simple case
-- add refresh to script
-- add mview statistics to script

-- Table is too large (limit 12 GB in oracle version), so I convert my single analytical table into a classic star schema, extract dictionaries to dimansions, making the hospitalization table a fact table. I also add a layer for analytics users (synonyms, views for mv, privs)
-- institution_nip_code is a candidate for dimension cardinality circa 8k
create materialized view dm_nfzhosp.mv_hospitalizations as
with 
 w_hospitalizations as (
   select
      rok year
      ,miesiac month
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
   from dm_nfzhosp.hospitalization_source
   ) 
, w_nfz_dept_dict(id_nfz, region_name, nfz_abbr) as (
   select 1 ,Dolnośląski , DŚ union all
   select 2, Kujawsko-Pomorski, KP  union all
   select 3, Lubelski, LB  union all
   select 4, Lubuski, LS  union all
   select 5, Łódzki, ŁD  union all
   select 6, Małopolski, MP  union all
   select 7, Mazowiecki, MZ  union all
   select 8, Opolski, OP  union all
   select 9, Podkarpacki, PK  union all
   select 10, Podlaski, PL  union all
   select 11, Pomorski, PM  union all
   select 12, Śląski, ŚL  union all
   select 13, Świętokrzyski, ŚK  union all
   select 14, Warmińsko-Mazurski, WM  union all
   select 15, Wielkopolski, WP  union all
   select 16, Zachodniopomorski, ZP 
)
select 
  hosp.year || / || lpad(hosp.month,2,0) as hosp_date_period
 ,dept_dict.nfz_abbr ||  ( || lpad(hosp.nfz_department_code,2,0) || ) dept_name_code
 ,hosp.institution_nip_code institution_nip_code
 ,hosp.nfz_service_code nfz_service_code
 ,hosp.nfz_contract_code nfz_contract_code
 ,case hosp.patient_gender 
    when K then F
    when M then M
    else -
 end as patient_gender
 ,replace(hosp.age_category,65 i więcej,>65) age_category
 ,case hosp.hosp_length_in_day_category 
    when 6 i więcej dni then >6
    when 0 dni then 0
    when 3-5 dni then 3-5
    when 1-2 dni then 1-2
   else - 
   end as hosp_length_in_day_category 
from w_hospitalizations hosp
   left join w_nfz_dept_dict dept_dict on hosp.nfz_department_code = dept_dict.id_nfz
   -- WHERE hosp.year >= 2020
;
/**
Dimension date as surogate vs yyyymmdd?
Human readable vs performance.
Small int vs number.
For my slow server and oracle express limits.. i prefer better optymalizatio
*/
create table dim_date as
select 
   rownum as id_date
   ,to_char(add_months(to_date(2019-01-01,YYYY-MM-DD), level)
      ,YYYY) as year
   ,to_char(add_months(to_date(2019-01-01,YYYY-MM-DD), level)
      ,MM) as month
from dual
connect by level <= months_between(to_date(2030-01-01,YYYY-MM-DD),to_date(2019-01-01,YYYY-MM-DD)) 
;
alter table hospitalizacje_csv add date_id number
; 
update hospitalizacje_csv h set date_id = (select id from dim_date dim where dim.year = h.rok and dim.month = h.miesiac)
;
drop table dim_date
;
create table dim_date as
select 
   rownum as id_date
   ,to_number(
      to_char(add_months(to_date(2017-01-01,YYYY-MM-DD), level -1)
      ,YYYY)) as year
   ,to_number(
      to_char(add_months(to_date(2017-01-01,YYYY-MM-DD), level -1)
      ,FMMM)) as month
from dual
connect by level <= months_between(to_date(2030-01-01,YYYY-MM-DD),to_date(2017-01-01,YYYY-MM-DD)) 
;

alter table hospitalizacje_csv add date_id number; 

update hospitalizacje_csv h set date_id = (select id from dim_date dim where dim.year = h.rok and dim.month = h.miesiac)
;
desc hospitalization_source;

update hospitalizacje_csv h set date_id = (select id from dim_date dim where dim.year = h.rok and dim.month = h.miesiac)
;

with 
 w_hospitalizations as (
   select
      rok year
      ,miesiac month
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
   from dm_nfzhosp.hospitalization_source
   ) 
, w_nfz_dept_dict(id_nfz, region_name, nfz_abbr) as (
   select 1 ,Dolnośląski , DŚ union all
   select 2, Kujawsko-Pomorski, KP  union all
   select 3, Lubelski, LB  union all
   select 4, Lubuski, LS  union all
   select 5, Łódzki, ŁD  union all
   select 6, Małopolski, MP  union all
   select 7, Mazowiecki, MZ  union all
   select 8, Opolski, OP  union all
   select 9, Podkarpacki, PK  union all
   select 10, Podlaski, PL  union all
   select 11, Pomorski, PM  union all
   select 12, Śląski, ŚL  union all
   select 13, Świętokrzyski, ŚK  union all
   select 14, Warmińsko-Mazurski, WM  union all
   select 15, Wielkopolski, WP  union all
   select 16, Zachodniopomorski, ZP 
)
select 
 (select id from dim_date dim where dim.year = hosp.year and dim.month = hosp.month)  dim_id
 ,dept_dict.nfz_abbr ||  ( || lpad(hosp.nfz_department_code,2,0) || ) dept_name_code
 ,hosp.institution_nip_code institution_nip_code
 ,hosp.nfz_service_code nfz_service_code
 ,hosp.nfz_contract_code nfz_contract_code
 ,case hosp.patient_gender 
    when K then F
    when M then M
    else hosp.patient_gender 
 end as patient_gender
 ,replace(hosp.age_category,65 i wiecej,>65) age_category
 ,case substr(hosp.hosp_length_in_day_category,0,1)
    when 6 then >6
    when 0 then 0
    when 3 then 3-5
    when 1 then 1-2
   else hosp.hosp_length_in_day_category
   end as hosp_length_in_day_category 
from w_hospitalizations hosp
   left join w_nfz_dept_dict dept_dict on hosp.nfz_department_code = dept_dict.id_nfz
;
select * from dim_date;


select value from nls_database_parameters where parameter = NLS_CHARACTERSET;
;
-- 20240528
drop table dm_nfzhosp.dim_nfzcontract
;
--CREATE TABLE dim_nfzcontract AS
select 
   cast(rownum as number(4)) as id_contract
   ,code
   ,sysdate as create_dt
   ,uid
from (
   select 
      distinct(value) as code
   from (select value from (select distinct (f.nfz_contract_code) as value from f_hospitalizations f))
)
;
--total hospitalization
--drop view dm_nfzhosp.rpt_totalhosp;
create or replace view rpt_totalhosp as
select to_char(
      count(1),999,999,999
   ) as all_hosp 
from dm_nfzhosp.f_hospitalizations
;
select all_hosp 
from rpt_totalhosp
;
--cost 61550
--WITH
--w1(PERIOD, hosp_count) AS (
--SELECT to_char(EXTRACT(YEAR FROM TO_DATE(2022-06-04,YYYY-MM-DD)) -1) AS PERIOD, COUNT(1) AS hosp_count
--   FROM dm_nfzhosp.f_hospitalizations facts
--   LEFT JOIN dm_nfzhosp.dim_date dimdate ON facts.dim_date_id = dimdate.id_date
--   WHERE dimdate.YEAR = EXTRACT(YEAR FROM TO_DATE(2022-06-04,YYYY-MM-DD)) - 1 --assume that today NOW sysdate is 2022-06-04
--      AND dimdate.MONTH < EXTRACT(MONTH FROM TO_DATE(2022-06-04,YYYY-MM-DD))  
--)
--,w2(PERIOD, hosp_count) AS (
-- SELECT to_char(EXTRACT(YEAR FROM TO_DATE(2022-06-04,YYYY-MM-DD))), COUNT(1)
--   FROM dm_nfzhosp.f_hospitalizations facts
--   LEFT JOIN dm_nfzhosp.dim_date dimdate ON facts.dim_date_id = dimdate.id_date
--   WHERE dimdate.YEAR = EXTRACT(YEAR FROM TO_DATE(2022-06-04,YYYY-MM-DD))
--      AND dimdate.MONTH < EXTRACT(MONTH FROM TO_DATE(2022-06-04,YYYY-MM-DD))
--)
--SELECT hosp_count - LAG (hosp_count, 1) OVER (ORDER BY hosp_count)
--FROM (
--   select PERIOD, hosp_count from w2
--   union all
--   select PERIOD, hosp_count from w1
--)
--where hosp_count is not null
--cost 61549
--;

--profiling
--  the distribution of hospitalizations across different departments
--create view prf_hosp_distr_per_dept as
create or replace view c##jdoe.prf_hosp_distr_per_dept as select 
   d.value,
   count(h.dim_department_id) as quantity from (
   select 
   dim_department_id,
   case
       WHEN quantity <= 500000 THEN 1: < 500K
       WHEN quantity <= 1000000 THEN 2: 500K - 1M
       WHEN quantity <= 1500000 THEN 3: 1M - 1.5M
       WHEN quantity <= 2000000 THEN 4: 1.5M - 2M
       WHEN quantity <= 2500000 THEN 5: 2M - 2.5M
       WHEN quantity <= 3000000 THEN 6: 2.5M - 3M
       WHEN quantity <= 3500000 THEN 7: 3M - 3.5M
       WHEN quantity <= 5000000 THEN 8: 3.5M - 5M
     else 9: 5M+
   end as quantity
   from
   (
      select dim_department_id, count(*) as quantity
      from dm_nfzhosp.f_hospitalizations
      group by dim_department_id
   )
) h
right join (
   select id, value
   from (
      values 
        (1, 1: < 500K),
        (2, 2: 500K - 1M),
        (3, 3: `1M - 1.5M),
        (4, 4: 1.5M - 2M),
        (5, 5: 2M - 2.5M),
        (6, 6: 2.5M - 3M),
        (7, 7: 3M - 3.5M),
        (8, 8: 3.5M - 5M),
        (9, 9: 5M+) as dict (id,value)
       ) d on h.quantity = d.value
group by d.value
order by 1
--connect by labels
;
desc dm_nfzhosp.F_HOSPITALIZATIONS
;
desc dm_nfzhosp.dim_date
;
select dd.year || - || lpad(dd.month,2,0) as ym, count(*) as quantity
from dm_nfzhosp.f_hospitalizations f
   join dm_nfzhosp.dim_date dd on f.dim_date_id = dd.id_date
group by dd.year, dd.month
order by 2 desc
;
select
   cat
   ,count(*) as quantity
from (
   select 
      inst
      ,case 
          when quantity <= 100 then 100
          when quantity <= 1000 then 1000
          when quantity <= 5000 then 5000
          when quantity <= 10000 then 10000
          when quantity <= 15000 then 15000
          when quantity <= 20000 then 20000
          when quantity <= 20000 then 20000
          when quantity <= 25000 then 25000
          when quantity <= 30000 then 30000
          when quantity <= 50000 then 50000
          when quantity <= 100000 then 100000
          when quantity <= 200000 then 200000
          when quantity <= 500000 then 500000
      else null
      end as cat
   from (
      select
         dim_institution_id inst
         ,count(*) as quantity
      from dm_nfzhosp.f_hospitalizations f
      group by dim_institution_id
      order by 2 desc
      )
   )
group by cat
order by 1
;
/
select 
age_category, count(age_category)
from dm_nfzhosp.f_hospitalizations f
group by age_category
fetch first 50 rows only
;

select
   cat
   ,count(cat) as quantity
from (
/
   select 
       inst,
        case 
            when quantity < 10000 and mod(round(quantity,-4), 2500) = 0 then quantity
            when quantity < 100000 then round(quantity, -5)
            when quantity < 1000000 then round(quantity, -6)
            else round(quantity, -6)
        end as cat  --up_to
        ,
           case 
            when quantity < 10000 and mod(round(quantity,-2), 2500) = 0 then 1
            when quantity < 100000 then 2
            else 3
        end as test1
        ,
        round(quantity, -4)
        ,
         quantity 
   from (
      select
         dim_institution_id inst
         ,count(dim_institution_id) as quantity
      from dm_nfzhosp.f_hospitalizations f
      group by dim_institution_id
      )
      /
   )
   
group by cat
order by cat
;
select  
   quantity
   ,log(10, quantity)
from (
 select
         dim_institution_id inst
         ,count(dim_institution_id) as quantity
      from dm_nfzhosp.f_hospitalizations f
      group by dim_institution_id
      )
      ;

select
   dd.year || '-H' ||
   case
      when dd.month between 1 and 6 then '1'
      else '2'
   end as period,
   count(f.dim_date_id) as quantity
from dm_nfzhosp.f_hospitalizations f
join dm_nfzhosp.dim_date dd on f.dim_date_id = dd.id_date
group by dd.year, 
         case
            when dd.month between 1 and 6 then '1'
            else '2'
         end
order by dd.year, period;
/
with hosp_per_inst as (
 select
   dim_institution_id inst
   ,count(dim_institution_id) as quantity
   from dm_nfzhosp.f_hospitalizations f
   group by dim_institution_id
   )
select
   case bin
      when 0 then '1: 0-10'
      when 1 then '2. 100'
      when 2 then '3: 1.000'
      when 3 then '4: 10.000'
      when 4 then '5: 100.000'
      when 5 then '6: 1.000.000'
    end as up_to
   ,count(*) as count
from
(
   select  
      inst
      ,quantity
      ,round(log(10, quantity)) as bin
   from hosp_per_inst
   )
group by bin
order by 1 asc
;
