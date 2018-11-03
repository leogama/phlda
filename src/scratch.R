setwd(rprojroot::is_git_root$find_file())
config <- yaml::read_yaml('config.yml')

library(magrittr)

# dataset annotation
info <- config$geo_datasets %>%
    lapply(function(gse_id) {
        gse_id %>%
            sprintf(fmt='output/info/%s.txt') %>%
            dget()
    })
get_info <- function(name) sapply(info, getElement, name=name)
data.frame(gse_id=config$geo_datasets,
           platform=paste0('GPL', get_info('gpl')),
           suppfile=get_info('suppfile'),
           n_samples=get_info('n_samples')) %>%
    write.table('annot/datasets.tsv', row.names=F, sep='\t', quote=F)


gse_id <- config$geo_datasets[1]

# get data
gse_file <- file.path('cache', 'processed', sprintf('%s.rda', gse_id))
gse <- GEOquery::getGEO(gse_id, destdir='data/processed')[[1]]


# sample annotation
pData(gse)$her2 <- as_factor(pData(gse))  # HER2+ or HER2-
pData(gse)$treatment <- as_factor(pData(gse))  # anti-HER2 treatment (trastuzumab, none...)
pData(gse)$outcome <- as_factor(pData(gse))  # pCR or RD

# cache
save(gse, file=gse_file)
