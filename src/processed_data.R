suppressMessages({
    library(GEOquery)
    library(magrittr)
    source('lib/R/utils.R')
})

gse_id <- snakemake@wildcards$gse_id
output <- unlist(snakemake@output)

gse_id %>%
    getGEO(destdir=dirname(output[1])) %>%
    getElement(1) %>%
    pData() %>%
    write.table(output[2], sep='\t', quote=FALSE)
