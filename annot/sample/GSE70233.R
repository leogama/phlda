her2: >
  c(
    '--' = 'HER2+',
    '10-20' = 'HER2+',
    '5-10' = 'HER2+',
    '2-5' = 'HER2+',
    '<2' = 'HER2-'
  ) %>% extract(pheno[['FISH:ch1']])
treatment: >
  rep.int('trastuzumab', nrow(pheno))
outcome: >
  c(
    'B' = 'RD',
    'G' = 'pCR'
  ) %>% extract(pheno[['path cr:ch1']])
