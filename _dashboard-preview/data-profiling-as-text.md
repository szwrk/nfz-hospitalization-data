CONNECT c##jdoe/oracle@datamart;

# Data Profiling - Text Version
## Reports
**1. Distribution of hospitalizations across different departments**

- _Distribution of hospitalizations across different departments?_

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

**2. Distribution of date**
```sql
SELECT
   ym,
   quantity
FROM C##JDOE.prf_date_distr_histogram;
``

```
YM                                                  QUANTITY
------------------------------------------------- ----------
2018-03                                               356677
2017-03                                               356385
2018-10                                               344234
2017-10                                               343732
2019-03                                               340307
2019-10                                               339088
2018-01                                               333154
2019-04                                               329828
2019-01                                               329817
2017-11                                               329307
2017-01                                               329066
(...)
2021-04                                               219797
2021-01                                               211185
2020-12                                               201980
2020-05                                               197001
2020-11                                               172620
2020-04                                               144646

72 rows selected. 
```
;
