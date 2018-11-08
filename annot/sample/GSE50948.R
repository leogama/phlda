her2: >
  pheno[['her2:ch1']]
treatment: >
  c(
    'neoadjuvant doxorubicin/paclitaxel (AT) followed by cyclophosphamide/methotrexate/fluorouracil (CMF)' = 'none', 
    'neoadjuvant doxorubicin/paclitaxel (AT) followed by cyclophosphamide/methotrexate/fluorouracil (CMF) + Trastuzumab for 1 year' = 'trastuzumab'
  ) %>% extract(pheno[['treatment:ch1']])
outcome: >
  pheno[['pcr:ch1']]
