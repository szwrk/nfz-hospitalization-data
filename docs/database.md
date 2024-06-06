## Database details
### DB Instance

| Object Type                | Object Name                        | Description                           |
|----------------------------|------------------------------------|---------------------------------------|
| **Pluggable Database (PDB)**| datamart                           |                                       |
| **Application schema**     | dm_nfzhosp                         |    

### Roles

| Role         | Description                           |
|--------------|---------------------------------------|
| R_ENGINEER   | Used for developers with strong privileges.   |
| R_ANALYST    | Used for analysts.                             |

### Users

| User       | Description              |
|------------|--------------------------|
| sysdm      | Data Mart Administrator  |
| C##JDOE    | Data Analyst 💁          |
| C##JSMITH  | Database Developer 🙋    |
| sys        | Oracle Root User         |

### Synonyms

| Synonym             | Description            |
|---------------------|------------------------|
| F_HOSPITALIZATIONS  |                        |

### Tables

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

### Views

| View                 | Description            |
|----------------------|------------------------|
| RPT_TOTALHOSP         |                        |
| ... others reports RPT_*|                  |
| V_HOSPITALIZATIONS  |                        |
| V_TRNSLTD_HOSPITALIZATIONS |                   |
