FeaturesCSV=$1

t2g=${FeaturesCSV/.csv/.Mismatch.t2g}
fa=${FeaturesCSV/.csv/.Mismatch.fa}
idx=${FeaturesCSV/.csv/.Mismatch.idx}

## 1. kite pre-processing
featuremap.py $FeaturesCSV --t2g FeaturesMismatch.t2g --fa ./FeaturesMismatch.fa --header --quiet

## 2. Build Index
## Build the kallisto index using the mismatch fasta and a k-mer length `-k` equal to the length of the Feature Barcodes:
kallisto index -i $idx -k 63 $fa
