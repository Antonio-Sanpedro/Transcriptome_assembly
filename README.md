# Malassezia globosa Transcriptome De Novo Assembly Protocol

This repository contains all the settings and files used for the de novo assembly of the Malassezia globosa transcriptome, which was employed for the analysis of the locus where the putative TER1 gene coding for the Telomerase RNA subunit was identified.

FILES:

- Trinity_samples.txt: A tab-delimited text file indicating the read files associated with each sample.

- REF_rRNA.fasta: Contains the mitochondrial rRNA sequences in FASTA format used as references to remove the remaining reads in the RNA-seq library files.

- Processing_and_Trinity_assembly.sh: This file contains the commands used to process FASTQ files and run Trinity.

- Assembly_statistics_and_mapping.sh: This file contains the commands used to obtain assembly statistics and map the assembled transcripts and processed reads to the reference genome.

- Trinity_assembly.Trinity.fasta: FASTA file output of the Trinity transcriptome assembly.

The processing of reads and the assembly pipeline are executed through the Processing_and_Trinity_assembly.sh and Assembly_statistics_and_mapping.sh scripts.

# Prerequisite

Prior to the analysis, it is required to download and decompress RNA-seq library files from NCBI (accession numbers: SRR2072129, SRR2072130, and SRR2072131).

# Initial quality control

The initial quality control procedure was executed using [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) to assess the quality of the raw reads and visualize the corresponding reports.

# Reads processing and de novo transcriptome assembly

The Processing_and_Trinity_assembly.sh script contains commands to process the reads using Trimmomatic and perform de novo assembly of the transcriptome with Trinity.

# Assembly statistics and transcript mapping

The Assembly_statistics_and_mapping.sh script includes commands to generate assembly statistics using the bundled TrinityStats.pl script. It also conducts mapping of the reconstructed transcripts using Gmap and evaluates the representation of the processed reads through Bowtie2.
