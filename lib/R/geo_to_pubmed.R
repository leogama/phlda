geo_to_pubmed <- function(gse_id) {
    pmid <- pmid_from_db(gse_id) %>% unname()
    if (!is.na(pmid)) return(pmid)
    pmid <- pmid_from_web(gse_id) %>% as.integer()
}

pmid_from_db <- function(gse_id) {
    con <- DBI::dbConnect(RSQLite::SQLite(), '/opt/databases/GEOmetadb.sqlite')
    on.exit(close(con))
    DBI::dbGetQuery(con, sprintf('SELECT pubmed_id FROM gse WHERE gse="%s"', gse_id))
}

pmid_from_web <- function(gse_id) {
    doc <- gse_id %>%
        sprintf('https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=%s', .) %>%
        httr::RETRY('GET', ., times=5L) %>%
        httr::content()

    # method 1
    pmid <- doc %>%
        rvest::html_node('.pubmed_id') %>%
        rvest::html_text()
    if (!is.na(pmid)) return(pmid)

    # method 2
    pmid <- doc %>%
        as.character() %>%
        stringr::str_extract('(?<=PMID: )\\d+')
    if (!is.na(pmid)) return(pmid)

    # method 3
    tryCatch({
        info_table <- doc %>%
            rvest::html_nodes('table:nth-of-type(2) table:nth-of-type(1)') %>%
            extract(1)
        info_table %>%
            xml2::xml_find_all(selectr::css_to_xpath('td table')) %>%
            xml2::xml_remove()
        pmid <- info_table %>%
            rvest::html_table() %>%
            getElement(1) %>%
            filter(grepl('citation', X1, ignore.case=T)) %>%
            with(X2) %>%
            sub('.+ ', '', .) %>%
            as.integer()
    }, error=function(...) NA)
}
