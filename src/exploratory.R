# vi:set ft=r fen fdc=2 fdm=expr fde=getline(v\:lnum)=~'^###'?'>1'\:'=' :

gse_id <- commandArgs(T)
load(file.path('cache', sprintf('%s.rda', gse_id)))

### Boxplot ###

boxdotplot <- function(plot_data, p_values, classes, gene, plot_title) {
    # Print an expression level boxplot and dotplot of 'gene', grouping samples  by 'classes'.
    #
    # Parameters:
    #   plot_data     [data.frame] Exression levels of one gene/probe.
    #   p_values      [numeric vector] P-values of t-tests between classes.
    #   classes       [character vector] Map: label -> class.
    #   gene          [character] Gene identifier.
    #   plot_title    [character] Label for graph title and file name.
    #
    # Returns:
    #   [list of grid plots] A boxplot (and a dotplot).

    # General configuration.
    plot <- ggplot(plot_data, aes(x=Class, y=Expression, fill=Class)) +
                   scale_x_discrete(breaks=classes, labels=names(classes)) +
                   scale_y_continuous(expand=c(0.15, 0)) +
                   ylab("Expression Intensity") +
                   guides(fill=F) +
                   theme(plot.title=element_text(vjust=1),
                         axis.title=element_text(vjust=0.3))

    # Plot specific configuration.
    boxplot <- plot + geom_boxplot() + aes(fill=Class)
    dotplot <- plot + geom_jitter(size=3, position=position_jitter(width=0.2)) +
                                  aes(colour=Class) + guides(colour=F)

    probe <- unique(plot_data$Probe)

    # Generate boxplot and dotplot for a single probe.
    if (length(probe) == 1L) {
        plot_title <- ggtitle(sprintf("%s: %s (%s) Expression", plot_title, gene, probe))

        # Add p-values above class labels.
        p_values <- paste(c("p ="), format(p_values, digits=3L, trim=T))
        p_values[1L] <- "T-test:"
        p_values <- annotate('text', label=p_values, x=seq_along(classes),
                             y=rep(-Inf, length(classes)), vjust=-1, size=4)
        # Add a mean marker to dotplot.
        mean <- stat_summary(fun.y='mean', geom='point', shape=23, size=4, fill='white', colour='grey50')

        return(list(boxplot=boxplot + p_values + plot_title,
                    dotplot=dotplot + p_values + mean + plot_title))

    # Generate side-by-side boxplots for multiple probes.
    } else {
        plot_title <- ggtitle(sprintf("%s: %s Expression", plot_title, gene))
        return(list(boxplot=boxplot + facet_wrap(~ Probe, nrow=1L) + plot_title))
    }
}

if (affymetrix) {
    gene_ids <- canonical_probeset(genes)
} else {
    gene_ids <- entrez_id(genes)
}

gene_plot <- list(outcome=pData(gse)[['outcome']],
                  expression=exprs(gse)[gene_id, ]) %>%
    as.data.frame() %>%
    ggplot(aes(x=outcome, y=expression))

sample_ids <- pData(gse[[id]]) %>%
    filter(her2 == 'HER2+', treatment != 'placebo') %>%
    with(geo_accession)
gse_subset <- gse[[id]][, sample_ids]
platform <- with(fData(gse_subset), setNames(`Gene Symbol`, ID))
main(pData(gse_subset), exprs(gse_subset), genes, platform, match='^outcome$')

### Distribution ###

PHLDA <- as.data.table(fData(gse[[id]]))[grep('PHLDA[123]', `Gene Symbol`), ]
setnames(PHLDA, c('ID', 'Gene Symbol'), c('probe_id', 'gene_symbol'))
setkey(PHLDA, gene_symbol, probe_id)
invisible(PHLDA[, gene_symbol := as.factor(gene_symbol)])

dat <- exprs(gse[[id]])[PHLDA$probe_id, ] %>%
    melt(varnames=c('probe_id', 'sample_id'), value.name='expression') %>%
    merge(y=pData(gse[[id]]), by.x='sample_id', by.y='geo_accession') %>%
    setDT()

density_plot <- function(dat, prefix) {
    pdf(sprintf('%s_density.pdf', prefix))
    sm::sm.density.compare(dat$expression, group=dat$probe_id, lty=as.numeric(PHLDA$gene_symbol))
    legend('topleft',
        legend=as.character(sprintf("%s (%s)", PHLDA$gene_symbol, PHLDA$probe_id)),
        col=seq.int(from=2, length=nrow(PHLDA)),  # colors start from 2 because yes
        lty=as.numeric(PHLDA$gene_symbol))
    dev.off()
}

density_plot(dat, 'PHLDA_all')
density_plot(dat[her2 == 'HER2+'], 'PHLDA_HER2+')

### Correlation with PHLDA2 probe ###

probe_id <- '209803_s_at'
e <- exprs(gse[[id]])
r <- apply(e, 1, cor, y=e[probe_id, ])
x <- names(r[abs(r) > .45])
x <- x[x != probe_id]
par(mfrow=c(3, 6))
for (p in x) plot(e[probe_id, ], e[p, ])

g <- get_probes(platform, x)
g <- get_probes(platform, names(g))
g <- g[sapply(g, length) > 1]
for (probes in g) {
    par(mfrow=c(1, 2))
    for (p in probes) plot(e[probe_id, ], e[p, ])
    scan(quiet=T)
}

### Paired samples ###

id <- 'GSE76360'
setwd(file.path(basedir, id))

dat <- pData(gse[[id]]) %>%
    extract(c('subject id:ch1', 'timepoint:ch1', 'er status:ch1', 'pr status:ch1', 'response at surgery:ch1')) %>% 
    setNames(c('subject_id', 'timepoint', 'er', 'pr', 'response'))

probe_id <- fData(gse[[id]]) %>% with(ID[grep('PHLDA3', Symbol)])
dat$PHLDA3 <- exprs(gse[[id]])[probe_id, ]
dat <- spread(dat, timepoint, PHLDA3)

res <- dat %>% with(t.test(baseline, post, paired=TRUE))
