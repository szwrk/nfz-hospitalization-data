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

