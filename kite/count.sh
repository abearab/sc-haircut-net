fastq_R1=$1
fastq_R2=$2
outdir=$3

WL='/rumi/shams/abe/anaconda3/envs/alignment/lib/python3.6/site-packages/kb_python/whitelists/10xv2_whitelist.txt.gz'


cd $outdir

## 3. Run kallisto
## Pseudoalign the reads:
kallisto bus -i $idx -o ./ -x 10xv2 -t 4 $fastq_R1 $fastq_R2

## 4. Run bustools
# For `bustools count`, use the mismatch t2g file.
bustools correct -w $WL ./output.bus -o ./output_corrected.bus

bustools sort -t 4 -o ./output_sorted.bus ./output_corrected.bus

mkdir ./featurecounts/

bustools count -o ./featurecounts/featurecounts --genecounts -g $t2g -e ./matrix.ec -t ./transcripts.txt ./output_sorted.bus # ???
