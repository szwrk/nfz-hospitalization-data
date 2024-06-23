# Installer docs
## About
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
## Dependencies
Files used in conjunction with the shell script:
```
├── install.sh
└── sql
    ├── 0-drop.sql
    ├── 1-setup-db.sql
    ├── 2-create-mart.sql
    ├── 3-load-dim.sql
    ├── 4-tests.sql
    └── 5-create-reports-as-analyst.sql
```

## Initial Setup
- Copy the repository
- Check server parameters (TNS, IP, service name) in the sql/ directory scripts
- Set up default encoding to UTF-8 (IDE + DB instance)
- Set up the Oracle database instance 
- Set up Apache Superset (not mandatory, just invoke reports views c##jdoe)
 
You can use Official Oracle Virtual Machine DB instance or Docker Image etc

## Run installer
- Open Linux terminal
- Execute install.sh

