#!/bin/sh
cd library
git pull
R_LIBS_USER='local/lib/R' Rscript setup/install.R
pip install --user snakemake
