config <- yaml::read_yaml('config.yml')
packages <- setdiff(config$packages, rownames(installed.packages()))

if (length(packages)) {
    source('https://bioconductor.org/biocLite.R')
    biocLite(packages, suppressUpdates=TRUE)
}
