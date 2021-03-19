
args='
  -q normal
  -o {log}.out
  -e {log}.err
  -J {params.job_name}
  -R "{params.memory} span[hosts=1] "
  -n {threads} '


#### execute snakemake ####

snakemake --drmaa "$args" \
    --snakefile Snakefile \
    --jobs 8 \
    --resources all_threads=8 \
    --latency-wait 50 \
    --rerun-incomplete  \
    --configfile config.yaml \
    --use-conda
