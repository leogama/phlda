parse_annotation <- function(gse_id, pheno) {
    pheno <- gse_id %>%
        sprintf(fmt='data/meta/%s.tsv') %>%
        read.delim(check.names=FALSE, colClasses='character')
    annot <- gse_id %>%
        sprintf(fmt='annot/sample/%s.R') %>%
        yaml::read_yaml() %>%
        lapply(function(x) eval(parse(text=x))) %>%
        lapply(unname)
    cbind(pheno, annot)
}

load_data <- function(gse_id) {
    simpleCache(sprintf('processed.%s', gse_id), {
        gse_id %>%
            getGEO(destdir='data/processed') %>%
            getElement(1)
    })
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

setup <- memoise::memoise(function(packages) {
    # find library's root directory
    root_dir <- rprojroot::is_git_root$find_file()
    if (getwd() != root_dir) setwd(root_dir)

    # wait server setup to finish
    finished_setup <- 'tail -1 ~/.nb.setup.log | grep -q "Done initial azure notebooks environment setup"'
    if (file.exists('~/.nb.setup.log')) {
        cat('Waiting server to finish setup..')
        retry(times=100L, delay=5L, {
            cat('.')
            stopifnot(!system(finished_setup))
        })
    }

    # load packages used here
    .libPaths(c('env/lib/R', .libPaths()))
    suppressPackageStartupMessages({
        library(magrittr)
        library(simpleCache)
        setCacheDir('cache')
 
        if (!missing(packages)) lapply(packages, require, character=TRUE)
    })

    # load and return global parameters
    yaml::yaml.load_file('config.yml')
})
