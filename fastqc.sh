PDIR=$1
fastqDIR=$2
qcDIR=$3
JOBS=$4

cd $PDIR

mkdir -p ${qcDIR}/;

for fq_file1 in ${fastqDIR}/*R1_001.fastq; do
    fq_file2=${fq_file1/_R1_001/_R2_001};
    sample_id=`basename $fq_file1`;
    sample_id=${sample_id/_S1_L001_R1_001.fastq/};
    echo '-----------' $sample_id '-----------';
    fastqc -q -t $JOBS -o ${qcDIR}/ $fq_file1 $fq_file2;
done

multiqc ${qcDIR}/ -n mutiqc-${qcDIR};
