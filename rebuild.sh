#!/bin/bash

db_tns_cdb="192.168.0.51:1521/free"
db_tns_datamart_pdb="192.168.0.51:1521/datamart"

dba_name="sys"
dev_name="c##jsmith"
datamart_admin_name="sysdm"
analyst_name=c##jdoe


check_success() {
    if [ $? -ne 0 ]; then
        echo "ERROR: The previous command failed. Exiting."
        exit 1
    fi
}

echo ""
echo "======================================"
echo " Data loading mode"
echo "======================================"
echo "1. Test mode (small dataset for testing)"
echo "2. Full data online (download and load entire CSV from public website)"
echo "3. Full data offline (manually load CSV from /data-full/)"
echo ""
read -p 'Select 1, 2, or 3...: ' load_mode

# DBA Credentials with validation (for fail-first approach)
echo ' '
read -s -p 'Enter dba password : ' dba_pass

# DEV Credentials with validation
echo ' '
read -s -p 'Enter dev password : ' dev_pass

# Data mart admin Credentials with validation
echo ' '
read -s -p 'Enter DM admin password : ' datamart_admin_pass

# Analyst Credentials with validation
echo ' '
read -s -p 'Enter analyst password : ' analyst_pass

# Only for tests
load_mode="3"
dba_pass="oracle"
dev_pass="oracle"
datamart_admin_pass="oracle"
analyst_pass="oracle"
# End Tests

# log the start time
instalattion_start_time=$(date +%s)

echo ' '
echo "Testing DB DBA connection..."
sql -S ${dba_name}@${db_tns_cdb} AS SYSDBA<<EOF
${dba_pass}
exit
EOF

echo ""
echo "======================================"
echo " Starting Drop Database Script"
echo "======================================"
cd sql || exit 1

sql -S ${dba_name}@${db_tns_cdb} AS SYSDBA @0-drop.sql<<EOF
${dba_pass}
exit
EOF

check_success
cd ..
echo "Drop Database Script Completed"
echo ""

echo "======================================"
echo " Starting Database Objects Setup Script"
echo "======================================"
cd sql || exit 1
sql -S ${dba_name}@${db_tns_cdb} AS SYSDBA @1-setup-db.sql<<EOF
${dba_pass}
exit
EOF
cd ..
echo "Database Objects Setup Script Completed"
echo ""

echo ' '
echo "Testing DB dev connection..."
sql -S ${dev_name}@${db_tns_datamart_pdb}<<EOF
${dev_pass}
exit
EOF

echo "======================================"
echo " Starting Data Mart Build Script"
echo "======================================"
cd sql || exit 1
sql -S ${dba_name}@${db_tns_cdb} AS SYSDBA @2-create-mart.sql <<EOF
${dba_pass}
exit
EOF

cd ..
echo "Data Mart Build Script Completed"
echo ""

echo "======================================"
echo " Loading Data"
echo "======================================"
# Execute SQL*Loader for 2019-2022

# log the start time
sqlloader_start_time=$(date +%s)

if [ "$load_mode" == "1" ]; then
    echo "Use small demo dataset."
    sqlldr ${dev_name}/${dev_pass}@${db_tns_datamart_pdb} control=ctl/demo_nfz_hospitalizations_2019-2022.ctl log=log/demo_nfz_hospitalizations_2019-2022.log direct=true 
elif [ "$load_mode" == "2" ]; then
    echo "Downloading full csv (>1GB)..."
    pwd
    # 2019-2021
    mkdir -p data-full

    curl -o data-full/nfz_hospitalizations_2019_2021.7z https://api.dane.gov.pl/media/resources/20230217/hospitalizacje.7z
    cd data-full
    7z x hospitalizacje.7z -odata-full    
    mv hospitalizacje.csv nfz_hospitalizations_2019_2021.csv
    # 2022
    curl -o data-full/nfz_hospitalizations_2022.csv https://api.dane.gov.pl/media/resources/20240123/hospitalizacje_2022.csv    
    mv hospitalizacje.csv nfz_hospitalizations_2022.csv
    # Load data
    cd ..
    sqlldr ${dev_name}/${dev_pass}@${db_tns_datamart_pdb} control=ctl/nfz_hospitalizations_2019-2022.ctl log=log/nfz_hospitalizations_2019-2022.log direct=true 
elif [ "$load_mode" == "3" ]; then
    sqlldr ${dev_name}/${dev_pass}@${db_tns_datamart_pdb} control=ctl/nfz_hospitalizations_2019-2022.ctl log=log/nfz_hospitalizations_2019-2022.log direct=true
fi

sqlloader_end_time=$(date +%s)
echo "Facts Load Completed"
sqlloader_load_duration=$(( sqlloader_end_time - sqlloader_start_time ))
echo "Loading time: $sqlloader_load_duration seconds"

echo ""
echo "Dimension Data Extracting..."

cd sql || exit 1
sql -S ${dba_name}@${db_tns_cdb} AS SYSDBA @3-load-dim.sql <<EOF
${dba_pass}
exit
EOF

echo "Dimension Extract Completed"

sql -S ${datamart_admin_name}@${db_tns_datamart_pdb} <<EOF
${datamart_admin_pass}
SET SERVEROUTPUT ON
PROMPT MView Initializing...
BEGIN
 DBMS_MVIEW.REFRESH(
    list => 'dm_nfzhosp.mv_hospitalizations',
    method => 'c'
);
END;
/
EXIT
EOF

sql -S ${datamart_admin_name}@${db_tns_datamart_pdb} <<EOF
${datamart_admin_pass}
SET SERVEROUTPUT ON
PROMPT Schema statistics calculation...
BEGIN
 DBMS_STATS.GATHER_SCHEMA_STATS(
    ownname => 'dm_nfzhosp'
);
END;
/
EXIT
EOF

echo "======================================"
echo " Tests"
echo "======================================"

sql -S ${datamart_admin_name}@${db_tns_datamart_pdb} @4-tests.sql <<EOF
${datamart_admin_pass}
exit
EOF

echo "======================================"
echo " Reports Views"
echo "======================================"

sql -S ${analyst_name}@${db_tns_datamart_pdb} @5-data-profiling.sql <<EOF
${datamart_admin_pass}
exit
EOF

sql -S ${analyst_name}@${db_tns_datamart_pdb} @6-create-reports-as-analyst.sql <<EOF
${datamart_admin_pass}
exit
EOF
echo "Installation Completed"
instalattion_end_time=$(date +%s)
instalattion_duration=$(( instalattion_end_time - instalattion_start_time ))
echo "Installation time: $instalattion_duration seconds"
echo ""