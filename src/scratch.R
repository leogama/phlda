root_dir <- rprojroot::is_git_root$find_file()
if (getwd() != root_dir) setwd(root_dir)
config <- yaml::yaml.load_file('config.yml')

.libPaths(c(.libPaths(), 'env/lib/R'))
library(magrittr)
library(simpleCache)
setCacheDir('cache')
source('lib/R/utils.R')

# dataset annotation
info <- config$geo_datasets %>%
    lapply(function(gse_id) {
        gse_id %>%
            sprintf(fmt='output/info/%s.txt') %>%
            dget()
    })
get_info <- function(name) sapply(info, getElement, name=name)
data.frame(gse_id=config$geo_datasets,
           platform=paste0('GPL', get_info('gpl')),
           suppfile=get_info('suppfile'),
           n_samples=get_info('n_samples')) %>%
    write.table('annot/datasets.tsv', row.names=F, sep='\t', quote=F)


(gse_id <- config$geo_datasets[3])

# sample annotation
pheno <- read.delim(sprintf('data/meta/%s.tsv', gse_id), check.names=FALSE, colClasses='character')
table_summary(pheno)

f <- file(sprintf('annot/sample/%s.R', gse_id), open='a')
(column <- select_column(pheno))
dput(file=f, setNames(nm=Filter(Negate(is.na), unique(pheno[[column]]))))
cat(file=f, ' %>% extract(pheno[["', column, '"]])', sep='')
close(f)

parse_annotation(gse_id, pheno)

# exploratory analysis
do.call(gridExtra::grid.arrange, c(lapply(config$genes, plot_expr, dat), nrow=1))
