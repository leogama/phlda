#!/bin/sh
cd library
git fetch && git reset --hard origin/master
R_LIBS_USER=env/lib/R Rscript setup/install.R
PYTHONUSERBASE=env pip install --user snakemake
