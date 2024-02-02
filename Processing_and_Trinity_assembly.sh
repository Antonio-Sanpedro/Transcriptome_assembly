#!/bin/bash

# Enable debugging mode
set -x

# Paths for input data and programs
READS_SAMPLE1_PATH=/path/to/your/directory/SRR2072129.fastq
READS_SAMPLE2_PATH=/path/to/your/directory/SRR2072130.fastq
READS_SAMPLE3_PATH=/path/to/your/directory/SRR2072131.fastq
SORTMERNA_PATH=$SORTMERNA_HOME
REF_rRNA_PATH=/path/to/your/directory/REF_rRNA.fasta
TRIMMOMATIC_PATH=/path/to/TRIMMOMATIC_HOME/Trimmomatic-0.39/trimmomatic-0.39.jar
ADAPTER_SEQUENCES_PATH=/path/to/TRIMMOMATIC_HOME/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa
TRINITY_PATH=$TRINITY_HOME
TRINITY_SAMPLES_PATH=/path/to/your/directory/Trinity_samples.txt

# Filtering rRNA, sample 1
$SORTMERNA_PATH --ref $REF_rRNA_PATH --reads $READS_SAMPLE1_PATH --fastx --workdir SRR2072129_PROCESSED --threads 10 --paired_in --other SRR2072129_rRNA_PROCESSED
# Filtering rRNA, sample 2
$SORTMERNA_PATH --ref $REF_rRNA_PATH --reads $READS_SAMPLE2_PATH --fastx --workdir SRR2072130_PROCESSED --threads 10 --paired_in --other SRR2072130_rRNA_PROCESSED
# Filtering rRNA, sample 3
$SORTMERNA_PATH --ref $REF_rRNA_PATH --reads $READS_SAMPLE3_PATH --fastx --workdir SRR2072131_PROCESSED --threads 10 --paired_in --other SRR2072131_rRNA_PROCESSED

# Extracting reads_1, sample 1
awk 'NR%8==1 || NR%8==2 || NR%8==3 || NR%8==4' SRR2072129_rRNA_PROCESSED.fq > SRR2072129_R1.fastq
# Extracting reads_2, sample 1
awk 'NR%8==5 || NR%8==6 || NR%8==7 || NR%8==0' SRR2072129_rRNA_PROCESSED.fq > SRR2072129_R2.fastq
# Extracting reads_1, sample 2
awk 'NR%8==1 || NR%8==2 || NR%8==3 || NR%8==4' SRR2072130_rRNA_PROCESSED.fq > SRR2072130_R1.fastq
# Extracting reads_2, sample 2
awk 'NR%8==5 || NR%8==6 || NR%8==7 || NR%8==0' SRR2072130_rRNA_PROCESSED.fq > SRR2072130_R2.fastq
# Extracting reads_1, sample 3
awk 'NR%8==1 || NR%8==2 || NR%8==3 || NR%8==4' SRR2072131_rRNA_PROCESSED.fq > SRR2072131_R1.fastq
# Extracting reads_2, sample 3
awk 'NR%8==5 || NR%8==6 || NR%8==7 || NR%8==0' SRR2072131_rRNA_PROCESSED.fq > SRR2072131_R2.fastq

# Removing low-quality reads and adapter sequences, sample 1
java -jar $TRIMMOMATIC_PATH PE -threads 10 -phred33 SRR2072129_R1.fastq SRR2072129_R2.fastq SRR2072129_R1_Q30.fastq SRR2072129_R1_Q30_unpaired.fastq SRR2072129_R2_Q30.fastq SRR2072129_R2_Q30_unpaired.fastq ILLUMINACLIP:$ADAPTER_SEQUENCES_PATH:2:30:10:1:true SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 AVGQUAL:30 MINLEN:25 2>Report_SRR2072129.txt
# Removing low-quality reads and adapter sequences, sample 2
java -jar $TRIMMOMATIC_PATH PE -threads 10 -phred33 SRR2072130_R1.fastq SRR2072130_R2.fastq SRR2072130_R1_Q30.fastq SRR2072130_R1_Q30_unpaired.fastq SRR2072130_R2_Q30.fastq SRR2072130_R2_Q30_unpaired.fastq ILLUMINACLIP:$ADAPTER_SEQUENCES_PATH:2:30:10:1:true SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 AVGQUAL:30 MINLEN:25 2>Report_SRR2072130.txt
# Removing low-quality reads and adapter sequences, sample 3
java -jar $TRIMMOMATIC_PATH PE -threads 10 -phred33 SRR2072131_R1.fastq SRR2072131_R2.fastq SRR2072131_R1_Q30.fastq SRR2072131_R1_Q30_unpaired.fastq SRR2072131_R2_Q30.fastq SRR2072131_R2_Q30_unpaired.fastq ILLUMINACLIP:$ADAPTER_SEQUENCES_PATH:2:30:10:1:true SLIDINGWINDOW:4:15 LEADING:3 TRAILING:3 AVGQUAL:30 MINLEN:25 2>Report_SRR2072131.txt

# Formatting read headers for processing with Trinity, sample 1
cat SRR2072129_R1_Q30.fastq | sed 's/.1 /\/1 /g' > SRR2072129_R1_Q30_PROCESSED.fastq
cat SRR2072129_R2_Q30.fastq | sed 's/.2 /\/2 /g' > SRR2072129_R2_Q30_PROCESSED.fastq
# Formatting read headers for processing with Trinity, sample 2
cat SRR2072130_R1_Q30.fastq | sed 's/.1 /\/1 /g' > SRR2072130_R1_Q30_PROCESSED.fastq
cat SRR2072130_R2_Q30.fastq | sed 's/.2 /\/2 /g' > SRR2072130_R2_Q30_PROCESSED.fastq
# Formatting read headers for processing with Trinity, sample 3
cat SRR2072131_R1_Q30.fastq | sed 's/.1 /\/1 /g' > SRR2072131_R1_Q30_PROCESSED.fastq
cat SRR2072131_R2_Q30.fastq | sed 's/.2 /\/2 /g' > SRR2072131_R2_Q30_PROCESSED.fastq

# De novo transcriptome assembly
$TRINITY_PATH --seqType fq --max_memory 30G --samples_file $TRINITY_SAMPLES_PATH --CPU 10 --min_kmer_cov=2 --min_contig_length=100 --jaccard_clip --SS_lib_type FR --output Trinity_assembly

echo "Automated analysis process completed."

# Disable debugging mode
set +x
