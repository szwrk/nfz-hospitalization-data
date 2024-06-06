# install
## Initial Setup
- Copy the repository
- Check server parameters (TNS, IP, service name) in the sql/ directory scripts
- Set up default encoding to UTF-8 (IDE + DB instance)
- Set up the Oracle database instance 
- Set up Apache Superset (not mandatory, just invoke reports views c##jdoe)
 
You can use Official Oracle Virtual Machine DB instance or Docker Image etc

## Run installer
- Execute install.sh

>Installer responsibilities:
>- Create Pluggable Database on your DB isntance:
>   * Get user DB credentials
>   * Create Data mart, star schema structure
>   * Initialize database (pdb, tablespaces, schemas, roles, grants)  
>
>- ELT process:
>   * Load CSV data to Data mart schema (ask user, offline-local-file, online or demo csv)
>   * Create user reports (as Views) for use as data sources with Apache Superset or terminal SQLCl 
>   * Handle facts and dimensions table
>- Refresh Materialized Views
>- Calculate DB stats
>- Log results
>- Handle errors