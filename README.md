# Download raw data
I'm selecting SRA accession numbers and putting them into `SraAccList.txt` file. Then, I'm using `fastq-dump` command from SRA Toolkits library to download FASTQ file. 
```bash
nohup cat SraAccList.txt | while read line; do fastq-dump --split-files --O raw-data $line; done &> raw-data.log&
```

# Repair feautres

To measure DNA repair activities in single cell, we add polyadenylated DNA
hairpins that contain a single type of DNA lesion to a 10x Genomics 3'
gene expression experiment. Within the droplets active DNA repair
proteins released from single cells recognize and initiate repair on the
DNA hairpin substrates. This results in a strand incision event. These
strand incision events are then captured in a downstream library
preparation.

After sequencing, DNA repair libraries are aligned to a custom DNA repair
reference. The features present in features\_\*\_repair.tsv.gz are
single-base positions along the hairpin reference (e.g. Abasic\_1 is the
first nucleotide in the abasic containing substrate). These positions
correspond to the aligning 5´ end of the hairpin in read 2.

All hairpins have a 5´ and 3´ C3 spacer, except the Uracil\_biotin
substrate that has a 5´ biotin. Hairpin names indicate the DNA lesion
within the hairpin. 

The following table contains hairpin substrates, their sequence, the
position of the lesion, and the expected position of repair-induced
incision. 

_Note: The O6mG containing substrate is a direct reversal substrate. The
incision site is dependent upon Pst1 digestion._

## DNA repair substrates

| Hairpin name  | Sequence | Lesion position | Repair position  | Purchased from |
|---|---|---|---|---|
| Uracil  | GTCGTGATGCATGCCTGTATGTGACACAAGTAATTGTGTCACAUACAGGCATGCATCACGACAAAAAAAAAAAAAAAAAAAA | 44  | 45  | IDT |
| riboG  | ACTCGAGTCACACTCGTACTGATGCATGAGTAATCATGCATCArGTACGAGTGTGACTCGAGTAAAAAAAAAAAAAAAAAAAA | 44  | 44  | IDT |
| Abasic  | ACGTACGTTAGCATAACTGTAATCTTAATGTAAATTAAGATTA/idSp/AGTTATGCTAACGTACGTAAAAAAAAAAAAAAAAAAAA | 44  | 45,46 | IDT |
| Normal  | CGCTAGCCTTCAGCTATCTTCTACCCATCGTAAGATGGGTAGAAGATAGCTGAAGGCTAGCGAAAAAAAAAAAAAAAAAAAA | NA  | NA  | IDT |
| GU  | TGAATTCGAGAGTCGTTCGGCGATATAACGTAAGTTATATCGCUGAACGACTCTCGAATTCAAAAAAAAAAAAAAAAAAAAA | 44  | 45 | IDT |
| TI  | GAGCGCTACTCAGATGACTTCGAGTGATTGTAAAATCACTCGAIGTCATCTGAGTAGCGCTCAAAAAAAAAAAAAAAAAAAA | 44  | 45 | IDT |
| CI  | AGTGCACGCTCTATGTATCGAAGAGTTGTGTAAACAACTCTTCIATACATAGAGCGTGCACTAAAAAAAAAAAAAAAAAAAA | 44  | 45 | IDT |
| ethenoA  | AAGGCCTGATGACGCATATCTGAGTGCTGGTAACAGCACTCAG[ethenoA]TATGCGTCATCAGGCCTTAAAAAAAAAAAAAAAAAAAA | 44 | 45,46 | phosphoramidites from Glen Research |
| O6mG  | GTGTACAACATACGACTGCAGTAGAGTGCGTAAGCACTCTACT[O6mG]CAGTCGTATGTTGTACACAAAAAAAAAAAAAAAAAAAA | 44  | 47 | phosphoramidites from Glen Research |
| hmU | AATCGATGAGCTAGAGACGTCGAATTGCAGTAATGCAATTCGA[hmU]GTCTCTAGCTCATCGATTAAAAAAAAAAAAAAAAAAAA |  44 | 45  | phosphoramidites from Glen Research |
| Uracil\_biotin |  /5Biosg/GCTTGCCTTGTCGATCACAAGTATGTCAGGTAACTGACATACTUGTGATCGACAAGGCAAGCAAAAAAAAAAAAAAAAAAAA | 44  | 45  | IDT |
   
## Prepare 
[Here](https://github.com/hesselberthlab/sc-haircut/issues/3), I asked for the `hairpin.fa` file. Afterward, I need that in `.csv` format to continue with _kite_. Therefore, I'm using my `fatools` python module to convert fasta to csv.
```bash
python kite/fatools.py -i sc-haircut/data -m fa2csv -f hairpin.fa
```

