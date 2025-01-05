#!/bin/bash

#SBATCH --job-name=pbmm2_index
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=1:00:00
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT
#SBATCH --mail-user=edlarsen@colostate.edu
#SBATCH --output=pbmm2_index_log_%j.txt


##### DOWNLOAD REFERENCE GENOME FASTA FILE #####
#rsync -azvP rsync://ftp.ensembl.org/ensembl/pub/release-104/fasta/canis_lupus_familiaris/dna/Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa.gz .

# Check md5sum of FASTA file - results will be stored in the genomeDownload.log file
#rsync -avzP rsync://ftp.ensembl.org/ensembl/pub/release-104/fasta/canis_lupus_familiaris/dna/CHECKSUMS .
#grep ".dna.toplevel" CHECKSUMS
#sum Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa.gz

# extract compressed FASTA file
#gunzip Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa.gz

##### INDEX REFERENCE GENOME FASTA FILE WITH PBMM2 #####
pbmm2 index Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa CanFam31.mmi --preset HIFI