# _kite_: kallisto indexing and tag extraction

This package enables fast and accurate pre-processing of Feature Barcoding experiments, a common datatype in single-cell genomics. In Feature Barcoding assays, cellular data are recorded as short DNA sequences using procedures adapted from single-cell RNA-seq. 

The __kite ("kallisto indexing and tag extraction__") workflow prepares input files prior to running the [kallisto | bustools](https://www.kallistobus.tools/getting_started.html) scRNA-seq pipeline. Starting with a .csv file containing Feature Barcode names and Feature Barcode sequences, the program `featuremap.py` generates a "mismatch map" and outputs "mismatch" fasta and "mismatch" transcript-to-gene (t2g) files. The mismatch files, containing the Feature Barcode sequences and their Hamming distance = 1 mismatches, are used to run kallisto | bustools on Feature Barcoding data. 

The mismatch fasta file is used by `kallisto index` with a k-mer length `-k` set to the length of the Feature Barcode. 

The mismatch t2g file is used by `bustools count` to generate a Features x Cells matrix. 

In this way, kallisto | bustools will effectively search the sequencing data for the Feature Barcodes and their Hamming distance = 1 neighbors. We find that for Feature Barcodes of moderate length (6-15bp) pre-processing is remarkably fast and the results equivalent to or better than those from traditional alignment.

A walk-through from the kallisto | bustools [Tutorials](https://www.kallistobus.tools/tutorials) page is reproduced below, and a complete Feature Barcode analysis can be found in the [docs](https://github.com/pachterlab/kite/tree/master/docs/) directory of the `kite` GitHub repository.

## System Requirements
Feature Barcode pre-processing requires up-to-date versions of `kallisto` and `bustools`
```
Python3
kallisto v0.46 or higher
bustools v0.39.0 or higher
```
For downstream analysis, we use [ScanPy](https://scanpy.readthedocs.io/en/stable/installation.html) (Wolf et. al, Genome Biology 2018) and the [LeidenAlg](https://github.com/vtraag/leidenalg) clustering package (Traag et. al, arXiv 2018).

## 1. kite pre-processing

```bash
featuremap.py FeatureBarcodes.csv --t2g ./FeaturesMismatch.t2g --fa ./FeaturesMismatch.fa --header --quiet
```
The `featuremap.py` program is run prior to the standard kallisto | bustools pipeline. It takes a .csv input and outputs "mismatch" transcript-to-gene (t2g) and fasta (fa) files that can be used by kallisto | bustools to complete pre-processing (see below and Vignettes). The program takes a single argument, FeatureBarcodes.csv, and outputs mismatch fasta and t2g files.

`FeatureBarcodes.csv` path to a .csv-formatted file containing Feature Barcode names and sequences

`--t2g`     Filepath for newly generated .t2g file. Default ./FeaturesMismatch.t2g <br>
`--fa`      Filepath for newly generated .fa file. Default ./FeaturesMismatch.fa <br>
`--header`  Optional flag. Use --header if your CSV file contains a header. <br>
`--quiet`   Optional flag. Do not print run information to standard out

returns "mismatch" fasta and t2g files saved to the specified directory

### NOTE: Use only odd values for k-mer length during `kallisto index` 
To avoid potential pseudoalignment errors arising from inverted repeats, kallisto only accepts odd values for the k-mer length `-k`. If your Feature Barcodes have an even length, just add an appropriate constant base on one side and follow the protocol as suggested. For example, append an __A__ base to the CD3_TotalSeqB barcode AACAAGACCCTTGAG → AACAAGACCCTTGAGA. Adding constant bases in this way increases specificity and may be useful for experiments with low sequencing quality or very short Feature Barcodes.

Processing Feature Barcodes is similar to processing transcripts except instead of looking for transcript fragments of length `-k` (the k-mer length) in the reads, a "mismatch" index is used to search the raw reads for the Feature Barcode whitelist and mismatch sequences. Please refer to the [kallisto documentation](https://www.kallistobus.tools/documentation) for more information on the kallisto | bustools workflow. 

Because Feature Barcodes are typically designed to be robust to some sequencing errors, each Feature Barcode and its mismatches are unique across an experiment, thus each Feature Barcode equivalence class has a one-to-one correspondence to a member of the Feature Barcode whitelist. This is reflected in the t2g file, where each mismatch Feature Barcode points to a unique parent Feature Barcode from the whitelist, analogous to the relationship between genes and transcripts in the case of cDNA processing. 

## 2. Build Index
Build the kallisto index using the mismatch fasta and a k-mer length `-k` equal to the length of the Feature Barcodes:
```bash
kallisto index -i FeaturesMismatch.idx -k 15 ./FeaturesMismatch.fa
```
## 3. Run kallisto
Pseudoalign the reads:
```bash
$ kallisto bus -i FeaturesMismatch.idx -o ./ -x 10xv3 -t 4 $fastq_R1 $fastq_R2
```

## 4. Run bustools
For `bustools count`, use the mismatch t2g file. 
```bash
bustools correct -w ./10xv3_whitelist.txt ./output.bus -o ./output_corrected.bus
```
```bash
bustools sort -t 4 -o ./output_sorted.bus ./output_corrected.bus
```
```bash
mkdir ./featurecounts/
```
```bash
bustools count -o ./featurecounts/featurecounts --genecounts -g ./FeaturesMismatch.t2g -e ./matrix.ec -t ./transcripts.txt ./output_sorted.bus
```
## 5. Analyze count matrix
`Bustools count` outputs a .mtx-formatted Features x Cells matrix and vectors of gene names and cell barcodes (genes.txt and barcodes.txt). From here, standard analysis packages like ScanPy and Seurat can be used to continue the Feature Barcode analysis. For details, check out the [Jupyter notebook](https://github.com/pachterlab/kite/tree/master/docs/).
