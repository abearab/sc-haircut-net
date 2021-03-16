# A Simple Python Script to Convert FASTA file to CSV format - https://birdlet.github.io/2017/12/13/fasta2csv/
import sys, os
import matplotlib.pyplot as plt
import argparse
import warnings
import pandas as pd
warnings.filterwarnings("ignore")


def handler():
  parser = argparse.ArgumentParser()
  parser.add_argument("-i", "--indir", help="Absolute path to the directory (the project directory)", type=str)
  parser.add_argument('-b', '--bed', help='bed file name', type=str)
  parser.add_argument('-f', '--fa', help='fasta file name', type=str)
  parser.add_argument('-m', '--mode', help='run mode', type=str) # rm_intron OR fa2csv
  args = parser.parse_args()
  return args


def read_fasta(path):
    # Read in FASTA
    print('The Input file is: %s' %path)
    file = open(path)
    lines = file.read().splitlines()
    ids = [s[1:] for s in lines if '>' in s]
    n = [i for i,s in enumerate(lines) if '>' in s]
    n.append(len(lines))
    sequences = [''.join(lines[i+1:j]) for i,j in zip(n[:-1],n[1:])]
    file.close()
    fa = dict(zip(ids, sequences))
    return fa


def write_fasta(path, fa):
    file = open(path, 'w')
    for f in fa:
        file.write('>' + f + '\n')
        file.write(fa[f] + '\n')
    file.close()


def rm_intron(bed, fa):
    fa = read_fasta(fa)
    bed = pd.read_table(bed, header=0)
    tochange = bed[bed.blockCount > 1]
    starts = [tochange.blockStarts[i].split(',')[:tochange.blockCount[i]] for i in tochange.index.tolist() ]
    sizes = [tochange.blockSizes[i].split(',')[:tochange.blockCount[i]] for i in tochange.index.tolist() ]
    for id, x, l in zip(tochange.name.tolist(), starts, sizes):
        fa[id] = ''.join([fa[id][int(i):int(i)+int(j)] for i,j in zip(x,l)])
    return fa


def fa2csv():
    print ('wait')


def __main__():
    args = handler()
    os.chdir(args.indir)
    if args.mode == 'rm_intron':
        # Write fa file without intron sequences
        write_fasta(args.fa.replace('.fa','.nointron.fa'), rm_intron(args.bed, args.fa))
	print ('Write fa file without intron sequences: %s' %args.fa.replace('.fa','.nointron.fa') ) 
    elif args.mode == 'fa2csv':
	# Convert FASTA to CSV

# Output CSV file
print('The Output file is: %s' %output)
# Feature Barcode name  Feature Barcode sequence

