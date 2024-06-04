CONNECT c##jdoe/oracle@datamart;

-- Total Hospitalizations Report
CREATE OR REPLACE VIEW c##jdoe.rpt_totalhosp AS
SELECT to_char(
      COUNT(1),'FM999,999,999'
   ) AS value 
FROM dm_nfzhosp.f_hospitalizations
;
SELECT value
FROM rpt_totalhosp
;
SELECT TO_NUMBER(value,'FM999,999,999' ) --for apache superset
FROM rpt_totalhosp
;
-- Yearly_hospitalizations_comparison Report
CREATE OR REPLACE VIEW c##jdoe.rpt_yearly_hosps_comp AS
WITH
previous_year(PERIOD, hosp_count) AS (
SELECT to_char(EXTRACT(YEAR FROM TO_DATE('2022-06-04','YYYY-MM-DD')) -1) AS PERIOD, COUNT(1) AS hosp_count
   FROM dm_nfzhosp.f_hospitalizations facts
   LEFT JOIN dm_nfzhosp.dim_date dimdate ON facts.dim_date_id = dimdate.id_date
   WHERE dimdate.YEAR = EXTRACT(YEAR FROM TO_DATE('2022-06-04','YYYY-MM-DD')) - 1 --assume that today NOW sysdate is '2022-06-04'
      AND dimdate.MONTH < EXTRACT(MONTH FROM TO_DATE('2022-06-04','YYYY-MM-DD'))  
)
,current_year(PERIOD, hosp_count) AS (
 SELECT to_char(EXTRACT(YEAR FROM TO_DATE('2022-06-04','YYYY-MM-DD'))), COUNT(1)
   FROM dm_nfzhosp.f_hospitalizations facts
   LEFT JOIN dm_nfzhosp.dim_date dimdate ON facts.dim_date_id = dimdate.id_date
   WHERE dimdate.YEAR = EXTRACT(YEAR FROM TO_DATE('2022-06-04','YYYY-MM-DD'))
      AND dimdate.MONTH < EXTRACT(MONTH FROM TO_DATE('2022-06-04','YYYY-MM-DD'))
)
SELECT
   to_char(
      (SELECT hosp_count FROM current_year) - (SELECT hosp_count FROM previous_year)
   ,'S9999999') AS value
FROM dual
;
SELECT value AS BALANCE
FROM rpt_yearly_hosps_comp
;
--Waterfall
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
    HOSP_PERIOD
;
EXIT;
