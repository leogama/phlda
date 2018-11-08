her2: >
  c(
    'POS'='HER2+',
    'NEG'='HER2-'
  ) %>% extract(pheno[['her2:ch1']])
treatment: >
  rep.int('trastuzumab', nrow(pheno))
outcome: >
  pheno[['path_response:ch1']]
