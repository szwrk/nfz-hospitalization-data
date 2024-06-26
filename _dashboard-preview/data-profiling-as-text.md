CONNECT c##jdoe/oracle@datamart;

# Data Profiling - Text Version
## Reports
**1. Distribution of hospitalizations across different departments**

- _Distribution of hospitalizations across different departments_

```sql
SQL> SELECT value, quantity
FROM C##JDOE.PRF_HOSP_DISTR_PER_DEPT
;
```
Output:
```
VALUE          QUANTITY
------------ ----------
1: < 500K             0
2: 500K - 1M          6
3: 1M - 1.5M          5
4: 1.5M - 2M          3
5: 2M - 2.5M          1
6: 2.5M - 3M          0
7: 3M - 3.5M          1
8: 3.5M - 5M          0
9: 5M+                0
```

**2a. Distribution of hospitalizations by month**
```sql
SELECT
   ym,
   quantity
FROM C##JDOE.prf_date_distr_histogram;
```
```
YM                                                  QUANTITY
------------------------------------------------- ----------
2018-03                                               356677
2017-03                                               356385
2018-10                                               344234
(...)
2020-11                                               172620
2020-04                                               144646

72 rows selected. 
```

**2b. Distribution of hospitalizations by half-year**

```sql
SELECT
   period,
   quantity
FROM C##JDOE.prf_distr_histogram_by_hy;
```
```
PERIOD                                        QUANTITY
------------------------------------------- ----------
2017-H1                                        1974516
2017-H2                                        1953199
2018-H1                                        1981317
2018-H2                                        1927280
2019-H1                                        1954975
2019-H2                                        1887371
2020-H1                                        1480522
2020-H2                                        1413063
2021-H1                                        1441175
2021-H2                                        1672280
2022-H1                                        1675865
2022-H2                                        1832786

12 rows selected. 
```