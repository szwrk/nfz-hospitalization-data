LOAD DATA
CHARACTERSET UTF8
INFILE 'data-full/jgp.csv'
INFILE 'data-full/jgp.csv'
APPEND INTO TABLE dm_nfzhosp.dim_jgp
FIELDS TERMINATED BY '|' optionally enclosed by '"'
(
  group_code,
  product_code,
  name
)