#!/bin/bash

db_tns_cdb="192.168.0.51:1521/free"
db_tns_datamart_pdb="192.168.0.51:1521/datamart"

dba_name="sys"
dev_name="c##jsmith"

read -s -p 'Enter dba password : ' dba_pass
echo ' '
read -s -p 'Enter dev password : ' dev_pass

echo ""
echo "======================================"
echo " Data loading mode"
echo "======================================"
echo "1. Test mode (small dataset for testing)"
echo "2. Full data online (download and load entire CSV from public website)"
echo "3. Full data offline (manually load CSV from /data-full/)"
echo ""
read -p 'Select 1, 2, or 3...: ' load_mode

check_success() {
    if [ $? -ne 0 ]; then
        echo "ERROR: The previous command failed. Exiting."
        exit 1
    fi
}
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
sql -S ${dba_name}@${db_tns_cdb} AS SYSDBA @1-Setup-db.sql<<EOF
${dba_pass}
exit
EOF
cd ..
echo "Database Objects Setup Script Completed"
echo ""

echo "======================================"
echo " Starting Data Mart Build Script"
echo "======================================"
cd sql || exit 1
sql -S ${dba_name}@${db_tns_cdb} AS SYSDBA @2-create-mart.sql<<EOF
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

if [ "$load_mode" == "1" ]; then
    echo "Use small demo dataset."
    sqlldr ${dev_name}/${dev_pass}@${db_tns_datamart_pdb} control=ctl/demo_nfz_hospitalizations_2019-2022.ctl log=log/demo_nfz_hospitalizations_2019-2022.log
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
    sqlldr ${dev_name}/${dev_pass}@${db_tns_datamart_pdb} control=ctl/nfz_hospitalizations_2019-2022.ctl log=log/nfz_hospitalizations_2019-2022.log
elif [ "$load_mode" == "3" ]; then
    pwd
    sqlldr ${dev_name}/${dev_pass}@${db_tns_datamart_pdb} control=ctl/nfz_hospitalizations_2019-2022.ctl log=log/nfz_hospitalizations_2019-2022.log
fi
echo "Data Load Completed"
echo ""