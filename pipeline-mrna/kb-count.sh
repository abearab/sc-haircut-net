INDEX="/rumi/shams/abe/genomes/hg38/GRCh38.100-gencode.v37-modified/transcriptome.idx"
T2G="/rumi/shams/abe/genomes/hg38/GRCh38.100-gencode.v37-modified/transcripts_to_genes.txt"
SAMPLE=$1
OUT=$2
JOBS=$3

FASTQ1=${SAMPLE}_S1_L001_R1_001.fastq
FASTQ2=${SAMPLE}_S1_L001_R2_001.fastq

#### count transcripts 
kb count \
	--verbose \
	--h5ad \
	--cellranger \
	--report \
	-o $OUT \
	-t $JOBS \
	$FASTQ1 $FASTQ2 \
	-i $INDEX \
	-g $T2G \
    	-x 10xv2 \
