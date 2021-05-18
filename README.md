- [x] Download raw data

I'm selecting SRA accession numbers and putting them into `SraAccList.txt` file. Then, I'm using `fastq-dump` command from SRA Toolkits library to download FASTQ file. 
```bash
nohup cat SraAccList.txt | while read line; do fastq-dump --split-files --O raw-data $line; done &> raw-data.log&
```

- [ ] Run fastQC and multiQC: [pipeline-mrna](https://github.com/abearab/sc-haircut-net/blob/main/pipeline-mrna/)
- [ ] mRNA alignment and count: [pipeline-mrna](https://github.com/abearab/sc-haircut-net/blob/main/pipeline-mrna/)
- [ ] Hairpin alignment count:  [pipeline-repair](https://github.com/abearab/sc-haircut-net/tree/main/pipeline-repair) 
- [x] Re-analysis and preprocessing mix experiment data
- [x] Differential expression analysis task
- [x] Pathway enrichment analysis 
- [ ] Network analysis 

[comment]: <> (_____)
[comment]: <> (`rumi` server is an active server in [Goodarzi Lab]&#40;https://goodarzilab.ucsf.edu/&#41;, UCSF.)