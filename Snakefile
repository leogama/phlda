# vi: set ft=snakemake ts=2 sts=2 sw=2 :

from os import path

configfile: 'config.yml'

rule processed_data:
  output: 'data/processed/{gse_id}_series_matrix.txt.gz'
  log: 'log/{gse_id}.processed_data.log'
  message: 'Get processed data for GEO dataset {wildcards.gse_id}'
  run:
    destdir = path.dirname(output[0])
    if not path.exists(output[0]):
      shell('''
        Rscript -e 'GEOquery::getGEO("{wildcards.gse_id}", destdir="{destdir}")' &> {log}
      ''')

rule annotation:
  output: 'output/info/{gse_id}.txt'
  message: 'Getting dataset information from databases'
  script: 'src/annotation.R'

rule all:
  input: expand(rules.annotation.output, gse_id=config['geo_datasets'])

rule _report_:
  input: 'report/{doc}.Rmd'
  output: 'report/{doc}.ipynb'
  log: 'log/report.log'
  message: 'Generating Jupyter notebook: {wildcards.doc}'
  run:
    shell('notedown --knit --nomagic {input} > {output}')
    shell('sed -i -f report/kernelspec.sed {output}')

rule report:
  input: expand(rules._report_.output, doc=['datasets'])
