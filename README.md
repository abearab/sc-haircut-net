- [x] Human genome alignment task
- [ ] Count repair feautres using _kite_
- [ ] Measure repair activity 
- [ ] Preprocessing single cell re-analysis
- [ ] Basic network reconstruction 
- [ ] ...



# Download raw data
I'm selecting SRA accession numbers and putting them into `SraAccList.txt` file. Then, I'm using `fastq-dump` command from SRA Toolkits library to download FASTQ file. 
```bash
nohup cat SraAccList.txt | while read line; do fastq-dump --split-files --O raw-data $line; done &> raw-data.log&
```

# Human genome sudo-alignment  
For the main alignment task, I've used `kb-count.sh`(https://github.com/abearab/sc-haircut-net/blob/main/kb-count.sh) file at `rumi` server which is an active server in [Goodarzi Lab](https://goodarzilab.ucsf.edu/), UCSF. 

# Repair feautres
We aim to use [_kite_](https://github.com/pachterlab/kite) as part of [kallisto | bustools](https://www.kallistobus.tools/) for counting hairpin features.
## Prepare hairpins sequence in `csv` format  
[Here](https://github.com/hesselberthlab/sc-haircut/issues/3), I asked for the `hairpin.fa` file. Afterward, I need that in `.csv` format to continue with _kite_. Therefore, I'm using my `fatools` python module to convert fasta to csv.
```bash
python kite/fatools.py -i sc-haircut/data -m fa2csv -f hairpin.fa
```
## Build hairpin index 

## Count hairpin features 

# Measure repair activity 
