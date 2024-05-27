# Analyzing 21,194,350 Hospitalization Records from Poland's National Health Fund NFZ (2019-2022)
**NFZ Hospitalization Data ETL & Visualization | A Low-Level Approach with SQL, Shell Scripts, SQLLoader and Apache Superset**



## Table of Contents
- [About the Project](#about-the-project)
- [Tech Stack](#tech-stack)
- [About the Data](#about-the-data)
  - [Domain Dictionaries](#domain-dictionaries)
  - [Model](#model)
- [Installation](#installation)
  - [Data Part](#data-part)
  - [Visualization Tool](#visualization-tool)
- [Source Data Preview](#source-data-preview)

## About the Project
This project is based on real NFZ data sourced from the open-data portal, dane.gov.pl.
The dataset comprises all hospitalizations covered by the NFZ (National Health Fund of Poland) in 2019-2022 *.

- [Dane dotyczące hospitalizacji rozliczonych JGP w latach 2019-2021 ](https://dane.gov.pl/pl/dataset/3009,dane-dotyczace-hospitalizacji-rozliczonych-jgp-w-l/resource/45162) (containt hospitalizations start with 2017, 2018)
- [Dane dotyczące hospitalizacji rozliczonych JGP w latach 2022 ](https://dane.gov.pl/pl/dataset/3009,dane-dotyczace-hospitalizacji-rozliczonych-jgp-w-l/resource/54046)

The dataset comprises over 20 million records, with each record representing an individual patient's hospitalization data.

It's based on the public goverment repositories hub named data.gov.pl.

- [Source Licence](https://creativecommons.org/publicdomain/zero/1.0/legalcode.pl)

Used repository is not bad quality, but I saw small differences between files. I want to make some improvements, create DWH star schema, materialized view as fact table, dimensions etc...
I will clean and process the data to visualize it with Apache Superset.

## Tech stack
This repository showcases my Data Engineering project, highlighting my diverse data-related skills. 
It includes database administration, data warehousing, and ETL development tasks.
My objective is to prepare and process this data for visualization purposes, including the creation of charts and dashboards. I aim to learn modern data visualization BI tool.

The project is currently only available on my localhost, so included some scripts and documentation images for the initial version.

- Apache Superset for visualisation
- Oracle SQL for cleaning data
- VirtualBox, network bridged adapter. VMs:
   * VM 1: Oracle Linux with DB 21
   * VM 2: Centos, Docker, Apache Superset container with cx_oracle connector
- MINGW Bash for shell scripting
- SqlLoader

- IDE:
   * SQLDeveloper 23 for DBA tasks and queries
   * Visual Studio Code with new Oracle plugin for new experience :)
   * SQLPlus & SQLCli
- Others 
   * PlantUml for diagrams



## Model

![Diagram](assets/diagram.png)
*Figure 1: DWH Model*

### Database Objects & Names Explanation
**Pluggable Database (PDB)**
- datamart

**Application schema**
- dm_nfzhosp

**Users**
- sysdm: Data Mart Administrator
- C##JDOE: Data Analyst
- C##JSMITH: Database Developer
- sys: Oracle Root User

**Roles**
- Role R_ENGINEER is used for develepers. That's have strong privilages. Granted user: C##JSMITH
- R_ANALYST is used for. Granted user: C##JDOE


### Domain dictionaries
The data contains some foreign keys pointing to static dictionaries:
- dim_discharge_mode_dict 
- dim_admission_mode_dict (both as general dictionary, no-changing dimension)
- dim_nfz_dept_dict (inline yet as CTE)
- dim_institution (#todo)

The dictionary source for Polish HL7 implementations includes:
- discharge modes https://www.cez.gov.pl/HL7POL-1.3.2/plcda-html-1.3.2/plcda-html/voc-2.16.840.1.113883.3.4424.13.11.36-2015-10-26T000000.html

## Installation

**Data Part:**

- Set up the Oracle database.
- Copy the repository
- Review server parameters (TNS, IP, service name) in the sql/ directory scripts and install.sh
- Run the install.sh script (the script will prompt for database passwords for security and a better user experience)

![Installation](assets/install.gif)

*Figure 1: Demonstration of the installation process (gif animations)*

**Visualization Tool:**

- Configure the Apache Superset datasource and dataset with c##jdoe credentials (analytical role), using SqlAlchemu url

`url
oracle+cx_oracle://c##jdoe:oracle@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.0.51)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=datamart)))
`
- Set up charts.

### Source Data preview
ROK;MIESIAC;OW_NFZ;NIP_PODMIOTU;KOD_PRODUKTU_KONTRAKTOWEGO;KOD_PRODUKTU_JEDNOSTKOWEGO;KOD_TRYBU_PRZYJECIA;KOD_TRYBU_WYPISU;PLEC_PACJENTA;GRUPA_WIEKOWA_PACJENTA;PRZEDZIAL_DLUGOSCI_TRWANIA_HOSPITALIZACJI;LICZBA_HOSPITALIZACJI
2022;4;"07";"1132866688";"03.4580.991.02";"5.51.01.0008013";6;2;"K";"65 i wiecej";"6 i wie™cej dni";"<5"
2022;8;"02";"5562239217";"03.4220.030.02";"5.51.01.0001087";3;2;"K";"45-64";"6 i wiecej dni";"<5"
2022;11;"03";"9462146139";"03.4580.991.02";"5.51.01.0008015";6;2;"K";"65 i wiecej";"6 i wiecej dni";"<5"
2022;9;"15";"7842008454";"03.4450.040.02";"5.51.01.0012014";3;2;"K";"65 i wiecej";"0 dni";"<5"
2022;4;"13";"6572195982";"03.4500.030.02";"5.51.01.0006109";6;2;"K";"65 i wiecej";"3-5 dni";"<5"

------------
## My notes
- top 5 of disase by age group
- increase in hospitalization count for each age group
- increase in hospitalization length for each age group

#### Key words
#nfz #data #etl #elt #bi #BuissnessInteligance #dataVisualisation #healthcare #dataengineering #analyst