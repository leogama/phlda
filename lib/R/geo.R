library(magrittr)
library(memoise)
source('lib/R/utils.R')

info_from_eutils <- memoise::memoise(function(gse_id) {
    id <- sprintf('%s[ACCN]', gse_id)
    id <- retry(rentrez::entrez_search(db='gds', term=id, retmax=1))
    retry(rentrez::entrez_summary(db='gds', id=id$ids)) %>%
        unclass()
})

info_from_metadb <- memoise::memoise(function(gse_id) {
    stopifnot(!is.na(db_file <- Sys.getenv('R_GEOMETADB', unset=NA)))
    conn <- DBI::dbConnect(RSQLite::SQLite(), db_file)
    on.exit(DBI::dbDisconnect(conn))
    gse_id %>%
        sprintf(fmt='SELECT * FROM gse WHERE gse="%s"') %>%
        DBI::dbGetQuery(conn=conn) %>%
        as.list()
})

info_from_web <- memoise::memoise(function(gse_id) {
    geo_url <- sprintf('https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=%s', gse_id) 
    doc <- geo_url %>%
        httr::RETRY(verb='GET', times=5L, quiet=TRUE) %>%
        httr::content(encoding='UTF-8')
    info_table <- doc %>%
        rvest::html_nodes('table:nth-of-type(2) table:nth-of-type(1)') %>%
        extract(1)
    info_table %>%
        xml2::xml_find_all(selectr::css_to_xpath('td table')) %>%
        xml2::xml_remove()
    info <- info_table %>%
        rvest::html_table() %>%
        getElement(1) %>%
        dplyr::filter(X1 != '') %$%
        setNames(X2, X1) %>%
        gsub('<!--(.|\n)*?-->', '', .) %>%
        as.list()
    info$geo_url <- geo_url
    info
})

geo_to_pubmed <- memoise::memoise(function(gse_id) {
    pmid <- tryCatch(info_from_metadb(gse_id)$pubmed_id, error=function(...) NA)
    if (is.na(pmid)) {
        info <- info_from_web(gse_id)
        pmid <- info %>%
            getElement(grep('citation', names(info), ignore.case=TRUE)) %>%
            stringr::str_extract('\\d+$')
    }
    if (is.na(pmid)) return(NA)
    info <- retry(rentrez::entrez_fetch(db='pubmed', id=pmid, rettype='xml')) %>%
        rentrez::parse_pubmed_xml() %>%
        unclass()
    attr(info, 'empty') <- NULL
    info$pubmed_url <- sprintf('https://www.ncbi.nlm.nih.gov/pubmed/%s', pmid)
    info$doi_url <- sprintf('https://doi.org/%s', info$doi)
    info
})
