rule bowtie_idx:
    """
    build bowtie2 index
    """
    input:
      HAIRCUT_FASTA
    output:
      HAIRCUT_FASTA.rsplit('.', 1)[0] + ".1.bt2"
    params:
      idx = HAIRCUT_FASTA.rsplit('.', 1)[0], 
      job_name = "bt2_idx",
      memory = "select[mem>30] rusage[mem=30]",
    log:
      os.path.join("logs", "bowtie2_index", "log.txt")
    threads: 12
    resources: all_threads=12
    shell:
      """
      bowtie2-build \
        --threads {threads} \
        {input} \
        {params.idx} 
      """

