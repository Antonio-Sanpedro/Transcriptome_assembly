#!/bin/bash

# Requires gmap, bowtie2, samtools installed
# Reads processed obtained with Processing_and_trinity_assembly.sh are in working directory
# Requires downloading the reference genome and the fasta file with CDS sequences from the NCBI to working directory (https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/010/232/095/GCA_010232095.1_ASM1023209v1/GCA_010232095.1_ASM1023209v1_genomic.fna.gz, and https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/181/695/GCA_000181695.2_ASM18169v2/GCA_000181695.2_ASM18169v2_cds_from_genomic.fna.gz, respectively)

# Enable debugging mode
set -x

# Paths for input data and programs
WORKING_DIRECTORY=/path/to/your/directory
TRINITY_FOLDER=$TRINITY_HOME
REF_GENOME_PATH=/path/to/your/directory/GCA_010232095.1_ASM1023209v1_genomic.fna
CDS_FROM_GENOME_PATH=/path/to/your/directory/GCA_000181695.2_ASM18169v2_cds_from_genomic.fna

# Assembly statistics
$TRINITY_FOLDER/util/TrinityStats.pl Trinity_assembly.Trinity.fasta > assembly_statistics.txt

# Mapping transcripts to the reference genome
# Building the reference genome database
gmap_build -d DB_GENOME $REF_GENOME_PATH -D $WORKING_DIRECTORY
# Aligning CDS to the reference genome
gmap -n 0 -D $WORKING_DIRECTORY -d DB_GENOME $CDS_FROM_GENOME_PATH -L 1500 -t 10 -f gff3_gene > Gmap_CDS_Mglobosa.gff3
# Aligning assembled transcripts with the reference genome
gmap -n 0 -D $WORKING_DIRECTORY -d DB_GENOME Trinity_assembly.Trinity.fasta -L 1500 -t 10 -f gff3_gene > Trinity_assembly_Mglobosa.gff3

# Bowtie2 mapping statistics
# Building the reference genome database
bowtie2-build $REF_GENOME_PATH Index_Genome

# Mapping reads processed to the reference genome
# Mapping sample 1
bowtie2 -x Index_Genome -1 SRR2072129_R1_Q30_PROCESSED.fastq -2 SRR2072129_R2_Q30_PROCESSED.fastq -p 10 -S mapping_reads_S1.sam 2> bowtie2_mapping_statistics_S1.txt
# Mapping sample 2
bowtie2 -x Index_Genome -1 SRR2072130_R1_Q30_PROCESSED.fastq -2 SRR2072130_R2_Q30_PROCESSED.fastq -p 10 -S mapping_reads_S2.sam 2> bowtie2_mapping_statistics_S2.txt
# Mapping sample 3
bowtie2 -x Index_Genome -1 SRR2072131_R1_Q30_PROCESSED.fastq -2 SRR2072131_R2_Q30_PROCESSED.fastq -p 10 -S mapping_reads_S3.sam 2> bowtie2_mapping_statistics_S3.txt
# Mapping globally
bowtie2 -x Index_Genome -1 SRR2072129_R1_Q30_PROCESSED.fastq,SRR2072130_R1_Q30_PROCESSED.fastq,SRR2072131_R1_Q30_PROCESSED.fastq -2 SRR2072129_R2_Q30_PROCESSED.fastq,SRR2072130_R2_Q30_PROCESSED.fastq,SRR2072131_R2_Q30_PROCESSED.fastq -p 10 -S mapping_reads.sam 2> bowtie2_mapping_statistics.txt
# File format conversion from SAM to BAM 
samtools view --threads 10 -b -S mapping_reads.sam > mapping_reads.bam
# Sort BAM file
samtools sort --threads 10 mapping_reads.bam -o mapping_reads_sorted.bam
# Create the index in BAI format for BAM file
samtools index -@ 10 mapping_reads_sorted.bam

echo "Automated analysis process completed."

# Disable debugging mode
set +x
