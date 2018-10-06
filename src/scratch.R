
gse_ids <- c(
    # adjuvant trastuzumab
    'GSE37946', 'GSE42822', 'GSE50948', 'GSE66305',
    # neoadjuvant trastuzumab
    # 'GSE22226', # two platforms...
    'GSE44272', 'GSE58984', 'GSE70233', 'GSE75678', 'GSE76360'
)

id <- tail(commandArgs(), 1)
stopifnot(startsWith(id, 'GSE'))

### Data ###

# select dataset
id <- gse_ids[9]
dir.create(file.path(basedir, id), showWarnings=F)
setwd(file.path(basedir, id))

# group annotation
pData(gse[[id]])$her2 <- as_factor(pData(gse[[id]]))  # HER2+ or HER2-
pData(gse[[id]])$treatment <- as_factor(pData(gse[[id]]))  # trastuzumab or placebo
pData(gse[[id]])$outcome <- as_factor(pData(gse[[id]]))  # pCR or RD

# cache
gse_file <- file.path(basedir, 'gse.rda')
save(gse, file=gse_file)
load(gse_file)
