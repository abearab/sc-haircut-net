rule extract_umi_barcode:
    """
    extract umi and cell barcode from read 1.
    reads with cell barcodes not matching the 10x 
    white list will be discarded (i.e. no error correction)
    """
    input:
      R1 = config["RAW_DATA"] + "/{sample}_R1.fastq",
      R2 = config["RAW_DATA"] + "/{sample}_R2.fastq",
      whitelist = config["10X_WHITELIST"]
    output:
      R1 = "{data}/fastqs/{sample}_R1_umi.fastq.gz",
      R2 = "{data}/fastqs/{sample}_R2_umi.fastq.gz" 
    params:
      bc_pattern = "CCCCCCCCCCCCCCCCNNNNNNNNNN",
      job_name = "{sample}.get_umi",
      memory = "select[mem>4] rusage[mem=4]",
    log: "../logs/extract_umi/{sample}.out"
    threads: 2 # for gzip
    conda: "../envs/alignment.yaml"
    resources: all_threads=2
    shell:
      """
      umi_tools extract \
        --bc-pattern {params.bc_pattern} \
        --stdin {input.R1} \
        --stdout {output.R1} \
        --read2-in {input.R2} \
        --read2-out={output.R2} \
        --whitelist={input.whitelist} \
        --filter-cell-barcode
      """ 

rule trim:
    """
    trim tso and polyA
    """
    input:
      "{data}/fastqs/{sample}_R2_umi.fastq.gz"
    output:
      "{data}/fastqs/{sample}_R2_umi_trimmed.fastq.gz"
    params:
      adapter3p = " -a AAAAAAAAAA ",
      adapter5p = " -g AAGCAGTGGTATCAACGCAGAGTACATGGG ",
      other_options = " --minimum-length=2 ",
      job_name = "{sample}.trim",
      memory = "select[mem>4] rusage[mem=4]",
    log: "{data}/logs/trim/{sample}.out"
    threads: 2 # for gzip
    resources: all_threads=2
    conda: "../envs/alignment.yaml"
    shell:
      """
      cutadapt \
        {params.adapter3p} \
        {params.adapter5p} \
        {params.other_options} \
        -o {output} \
        {input}
      """

