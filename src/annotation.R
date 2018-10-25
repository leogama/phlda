options(error=save.image())

source('lib/R/geo_to_pubmed.R')
packages <- c('magrittr', 'rentrez', 'RSQLite', 'xml2')
invisible(lapply(packages, library, character=TRUE))

con <- dbConnect(SQLite(), snakemake@config$GEOmetadb)
info <- snakemake@wildcards$gse_id %>%
    sprintf('SELECT title,summary,overall_design,pubmed_id FROM gse WHERE gse="%s"', .) %>% 
    dbGetQuery(con, .) %>%
    as.list()

if (is.na(info$pubmed_id)) {
    info$pubmed_id <- snakemake@wildcards$gse_id %>%
        pmid_from_web() %>%
        as.character()
}

if (!is.na(info$pubmed_id)) {
    fetch <- function() entrez_fetch(db='pubmed', id=info$pubmed_id, rettype='xml')
    retry <- function(...) tryCatch(fetch(), error=retry)
    record <- info$pubmed_id %>%
        as.character() %>%
        retry() %>%
        read_xml()
    info$article_title <- record %>%
        xml_find_all('.//ArticleTitle') %>%
        xml_text()
    info$article_abstract <- record %>%
        xml_find_all('.//AbstractText') %>%
        xml_text()
    fetch <- function() entrez_link(dbfrom='pubmed', id=info$pubmed_id, cmd='llinks')
    retry <- function(...) tryCatch(fetch(), error=retry)
    info$article_fulltext <- retry() %>%
        unlist() %>%
        getElement(1)
}

dput(info, file=snakemake@output[[1]])
