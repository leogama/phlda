export R_LIBS_USER="$PWD/env/lib/R"
mkdir -p "$R_LIBS_USER"
Rscript setup/packages.R

export PYTHONUSERBASE="$PWD/env"
SNAKEMAKE="$PYTHONUSERBASE/bin/snakemake"
if [ ! -f "$SNAKEMAKE" ]; then
    pip install --user snakemake
fi

python3 "$SNAKEMAKE" all -j
