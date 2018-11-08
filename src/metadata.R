library(magrittr)
source('lib/R/geo.R')

gse_id <- snakemake@wildcards$gse_id 
output <- snakemake@output[[1]]

info_eutils <- info_from_eutils(gse_id)
info_web <- info_from_web(gse_id)
info <- c(info_eutils, info_web)
try(info <- c(info_from_metadb(gse_id), info))

article <- geo_to_pubmed(gse_id)
if (!is.na(article)) {
    info$article_url <- article$doi_url
    info$article_title <- article$title
    info$article_abstract <- paste(article$abstract, collapse=' ')
}

dput(info, file=output)
