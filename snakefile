#!/usr/bin/snakemake --snakefile
# vi: set ft=snakemake ts=2 sts=2 sw=2:

import config
from snakemake.utils import R
R('str.split <- function(x) strsplit(x, "\\s+")[[1]]; source("config/__init__.py")')

rule processed_data:
  output: expand('data/processed/{gse_id}_series_matrix.txt.gz', gse_id=config.geo_datasets)
  log: 'log/processed_data.log'
  message: 'Get processed data from GEO'
  run: R('''
    for (gse_id in geo_datasets) {
        if (this_file_not_exist) getGEO(gse_id, destdir=dirname({output[0]}))
    }
  ''')
