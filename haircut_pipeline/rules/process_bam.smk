import os


rule append_tag:
    """
    add XT tag with chrom + pos
    """
    input:
      bam = os.path.join("{data}", "bam", "{sample}_haircut.bam")
    output:
      bam = os.path.join("{data}", "bam", "{sample}_haircut_tagged.bam"),
      bai = os.path.join("{data}", "bam", "{sample}_haircut_tagged.bam.bai")
    params:
      job_name = "{sample}.tag",
      memory = "select[mem>4] rusage[mem=4]",
    log:
      os.path.join("logs", "tag_sample", "{sample}")
    threads: 1
    resources: all_threads=1
    shell:
      """
      {SRC}/tag_bam {input.bam} {output.bam} "_" 2 3
      
      samtools index {output.bam}
      """

rule add_umis_to_bam:
    """
    identify and add UMI groups to bam as tag.
    """
    input:
      bam = os.path.join("{data}", "bam", "{sample}_haircut_tagged.bam"),
      bai = os.path.join("{data}", "bam", "{sample}_haircut_tagged.bam.bai")
    output:
      bam = temp(os.path.join("{data}", "bam", "{sample}_haircut_umitagged.bam")),
    params:
      job_name = "{sample}.group",
      memory = "select[mem>32] rusage[mem=32]",
    log:
      os.path.join("logs", "group_sample", "{sample}")
    threads: 2
    resources: all_threads=2
    conda: "envs/alignment.yaml"
    shell:
      """
      umi_tools group \
        --read-length True \
        --per-cell \
        -I {input.bam} \
        --output-bam True \
        --output-unmapped True \
        -S {output.bam}
      """

rule sort_by_cb:
    """
    sort bam by cell barcode tag 
    """
    input:
      bam = os.path.join("{data}", "bam", "{sample}_haircut_umitagged.bam"),
    output:
      bam = os.path.join("{data}", "bam", "{sample}_haircut_umitagged_sorted.bam")
    params:
      cbtag = "CB" ,
      job_name = "{sample}.sort",
      memory = "select[mem>120] rusage[mem=120]",
    log:
      os.path.join("logs", "sort_sample", "{sample}")
    threads: 24
    resources: all_threads=24
    conda: "envs/alignment.yaml"
    shell:
      """
      samtools sort \
          -t {params.cbtag} \
          -@ 23 \
          -o {output.bam} \
          {input.bam} 
      """

