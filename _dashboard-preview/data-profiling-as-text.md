CONNECT c##jdoe/oracle@datamart;

# Data Profiling - Text Version
## Reports
**1. Total Hospitalizations**

-  _How many hospitalizations for analyze?_

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