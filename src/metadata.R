library(magrittr)
source('lib/R/geo.R')

gse_id <- snakemake@wildcards$gse_id 

info <- info_from_eutils(gse_id)
info <- info_from_web(gse_id) %>% c(info)

article <- geo_to_pubmed(gse_id)
if (!is.na(article)) {
    info$article_url <- article$doi_url
    info$article_title <- article$title
    info$article_abstract <- paste(article$abstract, collapse=' ')
}

dput(info, file=snakemake@output[[1]])
