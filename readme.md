---
# Analyzing 21,194,349 Hospitalization Records from Poland's National Health Fund (NFZ)
**Comprehensive ETL, Data Warehousing, Processing & Visualization Project**

_A Low-Level Approach using SQL, Shell Scripts, SQLLoader, and Apache Superset_

---

## Project Overview
The goal of this project is to develop a comprehensive ETL (Extract, Transform, Load), Data Warehousing, and data visualization system to process over 21 million hospitalization records from Poland's National Health Fund (NFZ). The project aims to create an automated system that supports data profiling, reporting, and building analytical dashboards.

### Key Components:
- **ETL & Data Warehouse**: Automated extraction, transformation, and loading of data into a star schema data mart.
- **Reports & Dashboards**:
  - Data Profiling Dashboard (visualization + text reports)
  - Main Analytical Dashboard (visualization + text reports)

### Links:
- Screenshots, data analysis, exploratory data analysis, and technical details: [Docs.md](docs.md).
- For more details and full documentation, visit my webpage: [https://it.wilamowski.net](https://it.wilamowski.net/portfolio/).

### Data Used:
- The project uses real data from Poland's NFZ, sourced from the public portal [dane.gov.pl](https://dane.gov.pl). The data covers hospitalizations from 2017 to 2022.

### Main Features:
- **Environment Setup**: Automated configuration of the database and environment using Bash and SQL scripts.
- **Data Profiling**: Analysis of patient admission and discharge modes based on NFZ data.
- **Installation and Processing**: Scripts `install.sh` and `rebuild.sh` allow for installation and automated restoration of the system.

### Tech Stack:
| Tool/Software           | Description                                  |
|-------------------------|----------------------------------------------|
| **Apache Superset**      | BI Visualization tool                        |
| **Oracle SQL**           | Data cleaning and manipulation               |
| **SqlLoader**            | Data loading                                 |
| **VM 1**                 | Oracle Linux with Oracle DB 21 XE            |
| **VM 2**                 | CentOS, Docker, Superset with cx_oracle      |
| **SQLDeveloper 23**      | IDE for DBA tasks and queries                |
| **SQLPlus & SQLCli**     | Database command-line tools                  |
| **MINGW Bash**           | Shell scripting                              |
| **PlantUML**             | Diagram generation tool                      |
| **GIT**                  | Version control system                       |

---

## Results:
- **Dashboards**: A modern approach using Apache Superset to visualize the results of data processing. Users can explore interactive dashboards or view text-based reports.
- **Text Reports**: Classic approach using SQLCl to display data in a text-based report format.

### Documentation:
- **Installation**: Detailed installation guide and scripts available in the GitHub repository.
- **Data Profiling**: Scripts for data profiling and full analysis results are available for viewing and download.

