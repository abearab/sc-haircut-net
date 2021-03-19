rule bowtie_idx:
    """
    build bowtie2 index
    """
    input:
      config["HAIRCUT_FASTA"]
    output:
      config["HAIRCUT_FASTA"].rsplit('.', 1)[0] + ".1.bt2"
    params:
      idx = HAIRCUT_FASTA.rsplit('.', 1)[0], 
      job_name = "bt2_idx",
      memory = "select[mem>30] rusage[mem=30]",
    log:
      config["DATA"] + "/logs/bowtie2_index/log.txt"
    threads: 12
    resources: all_threads=12
    conda: "../envs/alignment.yaml"
    shell:
      """
      bowtie2-build \
        --threads {threads} \
        {input} \
        {params.idx} 
      """


rule bowtie_align:
    """
    run bowtie2
    """
    input:
      idx = HAIRCUT_FASTA.rsplit('.', 1)[0] + ".1.bt2",
      R1 = "{data}/fastqs/{sample}_R2_umi_trimmed.fastq.gz",
    output:
      bam = "{data}/bam/{sample}_haircut.bam"
    params:
      settings = " --norc ",
      idx = HAIRCUT_FASTA.rsplit('.', 1)[0],
      job_name = "{sample}.bt2",
      memory = "select[mem>30] rusage[mem=30]",
    log:
      "{data}/logs/bowtie2_align/{sample}"
    threads: 12
    resources: all_threads=12
    conda: "../envs/alignment.yaml"
    shell:
      """
        bowtie2 \
          -x {params.idx} \
          --threads {threads} \
          {params.settings} \
          {input.R1} \
          | samtools view -bS \
          | samtools sort -@ 11 \
          > {output.bam}  

      """

