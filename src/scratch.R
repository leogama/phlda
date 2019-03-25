root_dir <- rprojroot::is_git_root$find_file()
if (getwd() != root_dir) setwd(root_dir)
config <- yaml::yaml.load_file('config.yml')

.libPaths(c(.libPaths(), 'env/lib/R'))
library(magrittr)
library(simpleCache)
setCacheDir('cache')
source('lib/R/utils.R')


## dataset annotation ##

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


## sample annotation ##

pheno <- read.delim(sprintf('data/meta/%s.tsv', gse_id), check.names=FALSE, colClasses='character')
table_summary(pheno)

f <- file(sprintf('annot/sample/%s.R', gse_id), open='a')
(column <- select_column(pheno))
dput(file=f, setNames(nm=Filter(Negate(is.na), unique(pheno[[column]]))))
cat(file=f, ' %>% extract(pheno[["', column, '"]])', sep='')
close(f)

parse_annotation(gse_id, pheno)


## exploratory analysis ##

annot <- parse_annotation(gse_id)
gse <- simpleCache(sprintf('processed.%s', gse_id))

probes <- config$genes %>%
    sapply(function(gene) {
        fData(gse) %>%
            filter(`Gene Symbol` == gene) %>%
            extract(, 'ID')
    })

probes <- jetset::jmap('hgu133a', symbol=config$genes)

dat <- gse %>%
    exprs() %>%
    extract(probes, annot$geo_accession) %>%
    t()
colnames(dat) <- config$genes
dat <- annot %>%
    select(geo_accession, her2, treatment, outcome) %>%
    cbind(dat)

for (gene in config$genes) {
    plot <- ggplot(dat) + aes_string('outcome', gene) + geom_boxplot()
    ggsave(sprintf('%s.png', gene), plot, path='output')
}

plot <- qplot(PHLDA2, ERBB2, data=dat)
ggsave('corr.png', plot, path='output')
do.call(gridExtra::grid.arrange, c(lapply(config$genes, plot_expr, dat), nrow=1))


## differential expression ##
library(limma)

probes <- platform %>%
    sprintf(fmt='scores.%s') %>%
    get %>%
    rownames_to_column %>%
    filter(!duplicated(EntrezID)) %$%
    rowname

esubset <- eset[probes]

design <- cbind(RD=1, PCRvsRD=annot$outcome=='pCR')
fit <- lmFit(esubset, design)
fit <- eBayes(fit)
x <- topTable(fit, coef='PCRvsRD', n=Inf)
