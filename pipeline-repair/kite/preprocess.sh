indir=$1
FeaturesCSV=$2

t2g=${FeaturesCSV/.csv/.Mismatch.t2g}
fa=${FeaturesCSV/.csv/.Mismatch.fa}
idx=${FeaturesCSV/.csv/.Mismatch.idx}
kite='/rumi/shams/abe/Projects/sc-haircut-net/kite'

cd $indir

## 1. kite pre-processing
python ${kite}/featuremap.py $FeaturesCSV --t2g $t2g --fa $fa --header --quiet

## 2. Build Index
## Build the kallisto index using the mismatch fasta and a k-mer length `-k` equal to the length of the Feature Barcodes:
kallisto index -i $idx -k 63 $fa
