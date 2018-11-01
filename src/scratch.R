setwd('~/Projects/phlda')
config <- yaml::read_yaml('config.yml')


gse_id <- config$geo_datasets[1]
gse_file <- file.path('cache', 'processed', sprintf('%s.rda', gse_id))

# get data
gse <- GEOquery::getGEO(gse_id, destdir='data/processed')[[1]]

# study annotation

# sample annotation
pData(gse)$her2 <- as_factor(pData(gse))  # HER2+ or HER2-
pData(gse)$treatment <- as_factor(pData(gse))  # anti-HER2 treatment (trastuzumab, none...)
pData(gse)$outcome <- as_factor(pData(gse))  # pCR or RD

# cache
save(gse, file=gse_file)



#-------------------------------------------------------------

gse_ids <- c(
    # adjuvant trastuzumab
    'GSE37946', 'GSE42822', 'GSE50948', 'GSE66305',
    # neoadjuvant trastuzumab
    'GSE44272', 'GSE58984', 'GSE70233', 'GSE75678', 'GSE76360'
    # 'GSE22226' # two platforms...
    # 'GSE26639' # ???
)
