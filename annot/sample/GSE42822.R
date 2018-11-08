her2: >
  c(
    'her2.status (1: positive, 0: negative): 0' = 'HER2-', 
    'her2.status (1: positive, 0: negative): 1' = 'HER2+', 
    'her2.status (1: positive, 0: negative): NA' = NA
  ) %>% extract(pheno[['characteristics_ch1.14']])
treatment: >
  c(
    'FEC/TX' = 'trastuzumab',
    'FEC/TX+H' = 'none'
  ) %>% extract(pheno[['treatment.type:ch1']])
outcome: >
  c(
    '0' = 'RD',
    '1' = 'pCR'
  ) %>% extract(pheno[['pcr (1) vs rd (0):ch1']])
