#!/bin/sh
cd library
git pull
Rscript setup/install.R
pip install --user snakemake
