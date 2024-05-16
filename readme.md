# Analyzing 21,194,350 Hospitalization Records from Poland's National Health Fund (2019-2022)
**Repo title: NFZ Hospitalization Data ETL & Visualization | A Low-Level Approach with SQL, Shell Scripts, SQLLoader and Apache Superset**

That's repository contain my Data Engineering project.

## About project
This project is based on real NFZ data sourced from the open-data portal, dane.gov.pl.
The dataset comprises all hospitalizations covered by the NFZ (National Health Fund of Poland) in 2019-2022 *.

My objective is to prepare and process this data for visualization purposes, including the creation of charts and dashboards.
I want learn some modern tools for data visualisation.

Ad*
https://dane.gov.pl/pl/dataset/3009,dane-dotyczace-hospitalizacji-rozliczonych-jgp-w-l/resource/45162
https://dane.gov.pl/pl/dataset/3009,dane-dotyczace-hospitalizacji-rozliczonych-jgp-w-l/resource/54046

## Tech stack
The project is currently only available on my localhost, so I've included some scripts and documentation images for the initial version.

- Apache Superset for visualisation
- Oracle SQL for cleaning data
- VirtualBox, network bridged adapter. VMs:
   * VM 1: Oracle Linux with DB 21
   * VM 2: Centos, Docker, Apache Superset container with cx_oracle connector
- MINGW distro for runing shell script

- IDE:
   * SQLDeveloper 23
   * Visual Studio Code with new Oracle plugin for new experience :)
   
## About data
The dataset comprises over 20 million records, with each record representing an individual patient's hospitalization data.

It's based on the public goverment repository name data.gov.pl
Source data is good quality, but I want to make some improvments.

I'll try clean and process data for visualize it with Apache Superset.

### Domain dictionaries
The data contains some foreign keys pointing to static dictionaries:
- nfz_dept_dict
- w_discharge_mode_dict
- w_admission_mode_dict

To simplify and denormalize these dictionaries, I've opted for an "inline" approach using Common Table Expressions (CTEs) and inline values, rather than adding separate tables to the schema.

The dictionary source for Polish HL7 implementations includes:
- discharge modes https://www.cez.gov.pl/HL7POL-1.3.2/plcda-html-1.3.2/plcda-html/voc-2.16.840.1.113883.3.4424.13.11.36-2015-10-26T000000.html

## Install

Data part:
- you need oracle database
- copy repo
- check variables in install.sh and sql/ directory scripts
- run install.sh (on start script can ask for db passwords for few security reason)


### Source Data preview
ROK;MIESIAC;OW_NFZ;NIP_PODMIOTU;KOD_PRODUKTU_KONTRAKTOWEGO;KOD_PRODUKTU_JEDNOSTKOWEGO;KOD_TRYBU_PRZYJECIA;KOD_TRYBU_WYPISU;PLEC_PACJENTA;GRUPA_WIEKOWA_PACJENTA;PRZEDZIAL_DLUGOSCI_TRWANIA_HOSPITALIZACJI;LICZBA_HOSPITALIZACJI
2022;4;"07";"1132866688";"03.4580.991.02";"5.51.01.0008013";6;2;"K";"65 i wiecej";"6 i wiÄ™cej dni";"<5"
2022;8;"02";"5562239217";"03.4220.030.02";"5.51.01.0001087";3;2;"K";"45-64";"6 i wiÄ™cej dni";"<5"
2022;11;"03";"9462146139";"03.4580.991.02";"5.51.01.0008015";6;2;"K";"65 i wiecej";"6 i wiÄ™cej dni";"<5"
2022;9;"15";"7842008454";"03.4450.040.02";"5.51.01.0012014";3;2;"K";"65 i wiecej";"0 dni";"<5"
2022;4;"13";"6572195982";"03.4500.030.02";"5.51.01.0006109";6;2;"K";"65 i wiecej";"3-5 dni";"<5"

------------
## Idea
- top 5 of disase by age group
- Increase in hospitalization count for each age group
- Increase in hospitalization length for each age group

#### Key words
#nfz #data #etl #elt #bi #BuissnessInteligance #dataVisualisation #healthcare #dataengineering #analyst