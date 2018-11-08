her2: >
  rep.int('HER2+', nrow(pheno))
treatment: >
  c(
    'chemotherapy+trastuzumab+lapatinib' = 'trastuzumab+lapatinib', 
    'chemotherapy+trastuzumab' = 'trastuzumab', 
    'chemotherapy+lapatinib' = 'lapatinib'
  ) %>% extract(pheno[['arm description:ch1']])
outcome: >
  c(
    '0' = 'RD',
    '1' = 'pCR'
  ) %>% extract(pheno[['pcr (1=yes):ch1']])
