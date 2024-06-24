CONNECT c##jdoe/ORACLE@datamart;

## Facts
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
SELECT value, quantity
FROM C##JDOE.prf_hosp_distr_per_dept_histogram
;
/
## Date dimension
create or replace view c##jdoe.prf_date_distr_histogram as
select dd.year || '-' || lpad(dd.month,2,0) as ym, count(*) as quantity
from dm_nfzhosp.f_hospitalizations f
   join dm_nfzhosp.dim_date dd on f.dim_date_id = dd.id_date
group by dd.year, dd.month
order by 2 desc
;
/
SELECT
   ym,
   quantity
FROM C##JDOE.prf_date_distr_histogram
;
/

EXIT;
