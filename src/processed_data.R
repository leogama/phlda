suppressMessages({
    library(GEOquery)
    library(magrittr)
    library(simpleCache)
})

gse_id <- snakemake@wildcards$gse_id
output <- unlist(snakemake@output)

gse <- simpleCache(paste0('processed.', gse_id), {
    gse_id %>%
        getGEO(destdir=dirname(output[1])) %>%
        getElement(1)
})

        pData() %>%
        write.table(output[2], sep='\t', quote=FALSE)
