her2: >
  rep.int('HER2+', nrow(pheno))
treatment: >
  rep.int('trastuzumab', nrow(pheno))
outcome: >
  c(
    'NOR' = 'RD',
    'OBJR' = 'RD',
    'pCR' = 'pCR'
  ) %>% extract(pheno[['response at surgery:ch1']])
