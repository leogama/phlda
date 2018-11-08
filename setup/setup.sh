export PYTHONUSERBASE="$PWD/env"
export R_LIBS_USER="$PWD/env/lib/R"
Rscript setup/packages.R
pip install --user snakemake
python3 env/bin/snakemake all -j
