rule count_umis:
    """
    count up umis
    """
    input:
      bam = os.path.join("{data}", "bam", "{sample}_haircut_tagged.bam"),
      bai = os.path.join("{data}", "bam", "{sample}_haircut_tagged.bam.bai")
    output:
      os.path.join("{data}", "counts", "{sample}", "umitools_counts.tsv.gz")
    params:
      job_name = "{sample}.count",
      memory = "select[mem>16] rusage[mem=16]",
    log:
      os.path.join("logs", "count_sample", "{sample}")
    threads: 2
    resources: all_threads=2
    conda: "envs/alignment.yaml"
    shell:
      """
      umi_tools count \
        --per-gene \
        --gene-tag=XT \
        --per-cell \
        -I {input} \
        -S {output} 
      """

