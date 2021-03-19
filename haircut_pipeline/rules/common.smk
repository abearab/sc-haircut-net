""" Utils for Snakerules to count haircut single cell data """ 
import os

RAW_DATA = config["RAW_DATA"]
DATA = config["DATA"]
HC_SAMPLES = config["HAIRCUT_SAMPLES"]
BC_WHITELIST = config["10X_WHITELIST"]
MRNA_BARCODES = config["CELL_BARCODES"]
HAIRCUT_FASTA = config["HAIRCUT_FASTA"]
SRC = config["SRC"]

hc_to_10x_map = {}
for idx, sample in enumerate(HC_SAMPLES):
    hc_to_10x_map[sample] = MRNA_BARCODES[idx]


def all_input(wildcards):
    """
    Function defining all requested inputs for the rule all (below).
    """

    wanted_input = []

    if config["process_fastq"]["activate"]:
        wanted_input.extend(
          expand(os.path.join(
              "{data}","fastqs","{sample}_{read_id}_umi.fastq.gz"
              ),
            data = DATA, sample = HC_SAMPLES, read_id = ["R1", "R2"])
        )
    if config["process_fastq"]["activate"]:
        wanted_input.extend(
          expand(os.path.join(
              "{data}", "counts","{sample}_umitools_counts.tsv.gz"
          ), data = DATA, sample = HC_SAMPLES)
        )

      expand(os.path.join("{data}", "bam",
        "{sample}_haircut_umitagged_sorted.bam"),
         data = DATA, sample = HC_SAMPLES),

    if config["bowtie_idx"][]
    if config["bowtie_align"[]]
    if config["process_bam
    if config["count_umis


