# vi: set ft=snakemake ts=2 sts=2 sw=2 :

from os import path

configfile: 'config.yml'

rule information:
  output: 'data/info/{gse_id}.txt'
  message: 'Getting information for dataset {wildcards.gse_id}'
  script: 'src/information.R'

rule processed_data:
  output: 'data/processed/{gse_id}_series_matrix.txt.gz', 'data/meta/{gse_id}.tsv'
  message: 'Getting processed data from GEO for dataset {wildcards.gse_id}'
  script: 'src/processed_data.R'

rule annotation:
  output: 'annot/sample/{gse_id}.R'

rule all:
  input:
    expand(rules.information.output, gse_id=config['geo_datasets']),
    expand(rules.processed_data.output, gse_id=config['geo_datasets'])

rule _report_:
  input: 'doc/{doc}.Rmd'
  output: 'report/{doc}.ipynb'
  message: 'Generating Jupyter notebook: {wildcards.doc}'
  run:
    shell('notedown --knit --nomagic {input} > {output}')
    shell('sed -i -f doc/kernelspec.sed {output}')

rule report:
  input: expand(rules._report_.output, doc=['datasets', 'exploratory'])
