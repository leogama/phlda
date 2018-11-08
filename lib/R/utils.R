parse_annotation <- function(gse_id, pheno) {
    gse_id %>%
        sprintf(fmt='annot/sample/%s.R') %>%
        yaml::read_yaml() %>%
        lapply(function(x) eval(parse(text=x))) %>%
        lapply(unname)
}

retry <- function(expr, times=5L, delay=0L) {
    n <- 0L
    wrapper <- function(...) {
        if (delay) Sys.sleep(delay)
        n <<- n + 1L
        if (n < times)
            tryCatch(expr, error=wrapper)
        else 
            expr
    }
    suppressWarnings(wrapper())
}
