CONNECT c##jdoe/ORACLE@datamart;

/
create or replace view c##jdoe.prf_hosp_distr_per_dept_histogram as select 
   d.value,
   count(h.dim_department_id) as quantity from (
   select 
   dim_department_id,
   case
       WHEN quantity <= 500000 THEN '1: < 500K'
       WHEN quantity <= 1000000 THEN '2: 500K - 1M'
       WHEN quantity <= 1500000 THEN '3: 1M - 1.5M'
       WHEN quantity <= 2000000 THEN '4: 1.5M - 2M'
       WHEN quantity <= 2500000 THEN '5: 2M - 2.5M'
       WHEN quantity <= 3000000 THEN '6: 2.5M - 3M'
       WHEN quantity <= 3500000 THEN '7: 3M - 3.5M'
       WHEN quantity <= 5000000 THEN '8: 3.5M - 5M'
     else '9: 5M+'
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
        (1, '1: < 500K'),
        (2, '2: 500K - 1M'),
        (3, '3: 1M - 1.5M'),
        (4, '4: 1.5M - 2M'),
        (5, '5: 2M - 2.5M'),
        (6, '6: 2.5M - 3M'),
        (7, '7: 3M - 3.5M'),
        (8, '8: 3.5M - 5M'),
        (9, '9: 5M+') as dict (id,value)
       ) d on h.quantity = d.value
group by d.value
order by 1
/
;
/
--version 1 by month
create or replace view c##jdoe.prf_date_distr_histogram as
select dd.year || '-' || lpad(dd.month,2,0) as ym, count(*) as quantity
from dm_nfzhosp.f_hospitalizations f
   join dm_nfzhosp.dim_date dd on f.dim_date_id = dd.id_date
group by dd.year, dd.month
order by 2 desc
;
--version 2 by half-year
create or replace view c##jdoe.prf_distr_histogram_by_hy as
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
order by dd.year, period
;
-- Distribution histogram based on the number of hospitalizations by institution field
create view c##jdoe.prf_hosp_distr_histogram_by_inst as
with hosp_per_inst as (
 select
   dim_institution_id inst
   ,count(dim_institution_id) as quantity
   from dm_nfzhosp.f_hospitalizations f
   group by dim_institution_id
   )
select
   case bin
      when 0 then '1: 10'
      when 1 then '2. 100'
      when 2 then '3: 1.000'
      when 3 then '4: 10.000'
      when 4 then '5: 100.000'
      when 5 then '6: 1.000.000'
    end as up_to
   ,count(*) as quantity
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
--
-- Distribution based on the count of specific modes of patient discharge per admission, according to the NFZ (National Health Fund) modes of discharge and admission.
create view c##jdoe.prf_hosp_distr_admission_discharges as
select
    reason_for_admission,
    "1" AS dis_1,
    "2" AS dis_2,
    "3" AS dis_3,
    "4" AS dis_4,
    "6" AS dis_6,
    "7" AS dis_7,
    "8" AS dis_8,
    "9" AS dis_9,
    "10" AS dis_10,
    "11" AS dis_11
from (
   select
      adm.value_eng || ' (' || adm.id_position  || ')' as reason_for_admission
      ,f.admission_code
      ,f.discharge_code
   from dm_nfzhosp.f_hospitalizations f
   join dm_nfzhosp.dim_nfzadmissions adm on f.admission_code = adm.id_position
   ) 
pivot (
   count(*) 
   for discharge_code in (1,2,3,4,6,7,8,9,10,11)
)
;
SELECT * FROM c##jdoe.prf_hosp_distr_admission_discharges
;
EXIT;
