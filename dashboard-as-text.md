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

- _Compare hospitalizations from the previous year at the same point in time (on the same date)_

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