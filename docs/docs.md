# Docs
## Dashboards
### Dashboard I - Visual Version
#### Preview
![Dashboard](assets/as-dashboard.png)

#### Setup

![Settings-Datasets](assets/as-dataset.png)
_Views as Datasets_

![Settings-Charts](assets/as-charts.png)
_Charts_

![Settings-Dashboards](assets/as-dashboards.png)
_Dashboards_


### Dashboard II- Text Reports
Tip: CONNECT c##jdoe/oracle@datamart;
#### Reports
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

CONNECT c##jdoe/oracle@datamart;

## Data Profiling - Text Version
### Reports
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
**3. Distribution histogram based on the number of hospitalizations by institution field**
```sql
SELECT
   up_to,
   quantity
FROM c##jdoe.prf_hosp_distr_histogram_by_inst;
```


1: 0-10 1
2. 100  7
3: 1.000    83
4: 10.000   243
5: 100.000  391
6: 1.000.000    226


**4. Distribution histogram based on the count of specific modes of patient discharge per admission, according to the NFZ (National Health Fund) modes of discharge and admission.**


```sql
SELECT * 
FROM c##jdoe.prf_hosp_distr_histogram_admission
;
```
### Distribution of Patient Discharges and Admission Reason

| REASON_FOR_ADMISSION                                              | DIS_1 | DIS_2 | DIS_3 | DIS_4 | DIS_6 | DIS_7 | DIS_8 | DIS_9 | DIS_10 | DIS_11 |
|-------------------------------------------------------------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|--------------|--------------|
| Emergency admission - other cases (3)                             | 6919800     | 15455742    | 1055898     | 188649      | 709275      | 14814       | 2970        | 1122597     | 819          | 2382         |
| Planned admission based on a referral (6)                         | 8711580     | 18046503    | 407859      | 62466       | 238764      | 6309        | 2295        | 213738      | 639          | 2988         |
| Emergency admission due to transfer by the medical rescue team (2)| 1603881     | 4697712     | 493851      | 154932      | 203370      | 11586       | 978         | 1175358     | 480          | 903          |
| Admission of a newborn as a result of childbirth in this hospital (5)| 713970   | 191286      | 74289       | 1260        | 20469       | 72          | 219         | 11430       | 33           | 93           |
| Admission based on an oncology diagnostics and treatment card (11)| 271371      | 340449      | 5535        | 897         | 2766        | 75          | 30          | 9750        | 15           | 66           |
| Transfer from another hospital (8)                                | 75990       | 228732      | 58662       | 5751        | 5925        | 222         | 66          | 27066       | 12           | 6            |
| Forced admission (10)                                             | 1566        | 1263        | 75          | 27          | 60          | 0           | 0           | 99          | 3            | 0            |
| Planned admission of a person who received healthcare services out of turn, according to entitlements under the act (7)| 5088 | 13752 | 1581  | 18  | 39  | 9  | 6  | 24  | 0  | 0   |
| Admission of a person subject to compulsory treatment (9)         | 681         | 2616        | 243         | 69          | 21          | 3           | 6           | 150         | 3            | 0            |



## Setup

### Visualization Tool Setup

- Configure the Apache Superset datasource and dataset with c##jdoe credentials (analytical role), using SqlAlchemu url

```url
oracle+cx_oracle://c##jdoe:oracle@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.0.51)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=datamart)))
```
- Set up charts (but you can also use simple text-based version of reports)

### Database details
#### DB Instance

| Object Type                | Object Name                        | Description                           |
|----------------------------|------------------------------------|---------------------------------------|
| **Pluggable Database (PDB)**| datamart                           |                                       |
| **Application schema**     | dm_nfzhosp                         |    

#### Roles

| Role         | Description                           |
|--------------|---------------------------------------|
| R_ENGINEER   | Used for developers with strong privileges.   |
| R_ANALYST    | Used for analysts.                             |

#### Users

| User       | Description              |
|------------|--------------------------|
| sysdm      | Data Mart Administrator  |
| C##JDOE    | Data Analyst 💁          |
| C##JSMITH  | Database Developer 🙋    |
| sys        | Oracle Root User         |

#### Synonyms

| Synonym             | Description            |
|---------------------|------------------------|
| F_HOSPITALIZATIONS  |                        |

#### Tables

| Table               | Description            |
|---------------------|------------------------|
| DIM_CONTRACTS       |                        |
| DIM_DATE            |                        |
| DIM_DEPARTMENTS     |                        |
| DIM_INSTITUTIONS    |                        |
| DIM_NFZADMISSIONS   |                        |
| DIM_NFZDISCHARGE    |                        |
| DIM_SERVICES        |                        |
| HOSPITALIZACJE_CSV  |                        |
| MV_HOSPITALIZATIONS |                        |

#### Views

| View                 | Description            |
|----------------------|------------------------|
| RPT_TOTALHOSP         |                        |
| ... others reports RPT_*|                  |
| V_HOSPITALIZATIONS  |                        |
| V_TRNSLTD_HOSPITALIZATIONS |                   |

### Installer docs
#### About
Installer responsibilities:
- Create Pluggable Database on your DB isntance:
   * Get user DB credentials
   * Create Data mart, star schema structure
   * Initialize database (pdb, tablespaces, schemas, roles, grants)  

- ELT process:
   * Load CSV data to Data mart schema (ask user, offline-local-file, online or demo csv)
   * Create user reports (as Views) for use as data sources with Apache Superset or terminal SQLCl 
   * Handle facts and dimensions table
- Refresh Materialized Views
- Calculate DB stats
- Log results
- Handle errors
#### Dependencies
Files used in conjunction with the shell script:
```
├── install.sh
└── sql
    ├── 0-drop.sql
    ├── 1-setup-db.sql
    ├── 2-create-mart.sql
    ├── 3-load-dim.sql
    ├── 4-tests.sql
    ├── 5-data-profiling.sql
    └── 6-create-reports-as-analyst.sql
```

#### Initial Setup
- Copy the repository
- Check server parameters (TNS, IP, service name) in the sql/ directory scripts
- Set up default encoding to UTF-8 (IDE + DB instance)
- Set up the Oracle database instance 
- Set up Apache Superset (not mandatory, just invoke reports views c##jdoe)
 
You can use Official Oracle Virtual Machine DB instance or Docker Image etc

#### Run installer
- Open Linux terminal
- Execute install.sh

