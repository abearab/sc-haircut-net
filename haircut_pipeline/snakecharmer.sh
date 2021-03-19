#### execute snakemake ####

snakemake -p \
    --snakefile Snakefile \
    --jobs 8 \
    --resources all_threads=8 \
    --latency-wait 50 \
    --configfile config.yaml \
    --use-conda

