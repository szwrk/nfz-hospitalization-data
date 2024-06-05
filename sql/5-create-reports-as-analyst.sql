CONNECT c##jdoe/ORACLE@datamart;

-- Total Hospitalizations Report
CREATE OR REPLACE VIEW c##jdoe.rpt_totalhosp AS
   SELECT
      to_char(COUNT(1),
              'FM999,999,999') AS value
   FROM
      dm_nfzhosp.f_hospitalizations;

SELECT
   value
FROM
   rpt_totalhosp;

SELECT
   TO_NUMBER(value, 'FM999,999,999') --for apache superset
FROM
   rpt_totalhosp;
-- Yearly_hospitalizations_comparison Report
CREATE OR REPLACE VIEW c##jdoe.rpt_yearly_hosps_comp AS
   WITH previous_year (
      period,
      hosp_count
   ) AS (
      SELECT
         to_char(EXTRACT(YEAR FROM TO_DATE('2022-06-04', 'YYYY-MM-DD')) - 1) AS period,
         COUNT(1)                                                            AS hosp_count
      FROM
         dm_nfzhosp.f_hospitalizations facts
         LEFT JOIN dm_nfzhosp.dim_date           dimdate ON facts.dim_date_id = dimdate.id_date
      WHERE
            dimdate.year = EXTRACT(YEAR FROM TO_DATE('2022-06-04', 'YYYY-MM-DD')) - 1 --assume that today NOW sysdate is '2022-06-04'
         AND dimdate.month < EXTRACT(MONTH FROM TO_DATE('2022-06-04', 'YYYY-MM-DD'))
   ), current_year (
      period,
      hosp_count
   ) AS (
      SELECT
         to_char(EXTRACT(YEAR FROM TO_DATE('2022-06-04', 'YYYY-MM-DD'))),
         COUNT(1)
      FROM
         dm_nfzhosp.f_hospitalizations facts
         LEFT JOIN dm_nfzhosp.dim_date           dimdate ON facts.dim_date_id = dimdate.id_date
      WHERE
            dimdate.year = EXTRACT(YEAR FROM TO_DATE('2022-06-04', 'YYYY-MM-DD'))
         AND dimdate.month < EXTRACT(MONTH FROM TO_DATE('2022-06-04', 'YYYY-MM-DD'))
   )
   SELECT
      to_char((
         SELECT
            hosp_count
         FROM
            current_year
      ) -(
         SELECT
            hosp_count
         FROM
            previous_year
      ), 'S9999999') AS value
   FROM
      dual;

SELECT
   value AS balance
FROM
   rpt_yearly_hosps_comp;

--Waterfall chart
--rpt_hosps_monthly_diffs
--january is initial value, not diff
ALTER SESSION SET current_schema = c##jdoe;
CREATE OR REPLACE VIEW c##jdoe.rpt_hosps_monthly_diffs AS
WITH monthly_counts AS (
   SELECT
      dd.year  AS year,
      dd.month AS month,
      COUNT(1) month_count
   FROM 
      dm_nfzhosp.f_hospitalizations f JOIN dm_nfzhosp.dim_date dd ON f.dim_date_id = dd.id_date
   GROUP BY
      dd.year,
      dd.month
)
SELECT
   year || '/' || lpad(month, 2, '0') AS period,
   year as year,
   month_count,
   nvl(month_count - LAG(month_count, 1) OVER(partition by year ORDER BY year, month),month_count) AS diff_prev_month
FROM
   monthly_counts mc
ORDER BY
   year,
   month ASC
;

SELECT
   dd.month,
   COUNT(1) month_count
FROM
        f_hospitalizations f
   JOIN dim_date dd ON f.dim_date_id = dd.id_date
--WHERE
--   dd.year = 2022
GROUP BY
   dd.month
   
   ;
/

select period, month_count, diff_prev_month
from C##JDOE.RPT_HOSPS_MONTHLY_DIFFS
;
/

EXIT;
