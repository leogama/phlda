source('lib/R/geo.R')
packages <- c('magrittr', 'rentrez')
invisible(lapply(packages, library, character=TRUE))

info <- snakemake@wildcards$gse_id %>%
    info_from_eutils()
info <- snakemake@wildcards$gse_id %>%
    info_from_web() %>%
    c(info)

article <- snakemake@wildcards$gse_id %>%
    geo_to_pubmed()
if (!is.na(article)) {
    info$article_url <- sprintf('https://doi.org/%s', article$doi)
    info$article_title <- article$title
    info$article_abstract <- paste(article$abstract, collapse=' ')
}

try({
    meta_info <- snakemake@wildcards$gse_id %>%
        extract(c('title', 'summary', 'overall_design'))
})

dput(info, file=snakemake@output[[1]])
