CONNECT c##jdoe/oracle@datamart;

# Dashboard - Text Version
## Reports
**1. Total Hospitalizations**

-  _How many facts for analyze?_

```sql
SQL> SELECT value as TOTAL_HOSPITALIZATIONS_IN_DATASET
FROM rpt_totalhosp
;
```
Output:
```
TOTAL_HOSPITALIZATIONS_IN_DATASET
___________________________________
21,194,349
```


**2. Yearly Hospitalization Comparison**

- _Compare the number of hospitalizations from the previous year at the same point in time (on the same date)_

```sql
SQL> SELECT value as BALANCE 
FROM rpt_yearly_hosps_comp
;
```
Output:
```
BALANCE
______________________________
 +204084
```

**3. Monthly Hospitalization Comparison**

- _Compare the number of hospitalizations monthly. Show the current count for January_

```sql
SQL> SELECT 
    r.period
    , r.month_count
    , r.diff_prev_month
FROM RPT_HOSPS_MONTHLY_DIFFS r
WHERE r.year = 2022
;
```
Output:
```
PERIOD                                            MONTH_COUNT DIFF_PREV_MONTH
------------------------------------------------- ----------- ---------------
2022/01                                                236502          236502
2022/02                                                233503           -2999
2022/03                                                291638           58135
2022/04                                                302054           10416
2022/05                                                305431            3377
2022/06                                                306737            1306
2022/07                                                303161           -3576
2022/08                                                296762           -6399
2022/09                                                304887            8125
2022/10                                                313383            8496
2022/11                                                302807          -10576
```