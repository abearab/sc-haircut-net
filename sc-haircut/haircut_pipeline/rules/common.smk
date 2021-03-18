""" Utils for Snakerules to count haircut single cell data """ 

def all_input(wildcards):
    """
    Function defining all requested inputs for the rule all (below).
    """

    wanted_input = []

    # request goatools if 'activated' in config.yaml
    if config[""]["activate"]:
        wanted_input.extend(
            expand(
            )
        )

      expand("{data}/fastqs/{sample}_{read_id}_umi.fastq.gz",
        data = DATA, sample = HC_SAMPLES, read_id = ["R1", "R2"]),

      expand(os.path.join("{data}", "counts",
        "{sample}", "umitools_counts.tsv.gz"),
        data = DATA, sample = HC_SAMPLES),
      
      expand(os.path.join("{data}", "bam",
        "{sample}_haircut_umitagged_sorted.bam"),
         data = DATA, sample = HC_SAMPLES),

