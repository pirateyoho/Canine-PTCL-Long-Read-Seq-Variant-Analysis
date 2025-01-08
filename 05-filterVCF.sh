#!/bin/bash
#SBATCH --job-name=filterVCF
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=1:00:00
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT
#SBATCH --mail-user=edlarsen@colostate.edu
#SBATCH --output=filterVCF_log_%j.txt

######## install svpack ########
git clone https://github.com/PacificBiosciences/svpack.git
cd svpack

######## Return PASS SVs at least 50 bp long ########
./svpack filter --pass-only --min-svlen 50 ../../output/PTCL_StructuralVariants_CanFam3.vcf > ../../output/PTCL_StructuralVariants_CanFam3.filtered.vcf

######## Annotate SVs that impact genes ########
# Retrieve gff3 file for reference genome
rsync -azvP rsync://ftp.ensembl.org/ensembl/pub/release-104/gff3/canis_lupus_familiaris/Canis_lupus_familiaris.CanFam3.1.104.gff3.gz .
rsync -azvP rsync://ftp.ensembl.org/ensembl/pub/release-104/gff3/canis_lupus_familiaris/CHECKSUMS .
grep "CanFam3.1.104.gff3.gz" CHECKSUMS
sum Canis_lupus_familiaris.CanFam3.1.104.gff3.gz
gunzip Canis_lupus_familiaris.CanFam3.1.104.gff3.gz

# Add BCSQ tag to variants that impact genes
./svpack consequence ../../output/PTCL_StructuralVariants_CanFam3.filtered.vcf Canis_lupus_familiaris.CanFam3.1.104.gff3 > ../../output/PTCL_StructuralVariants_CanFam3.filtered.ann.vcf

######## Subset only SVs that impact genes ########
bcftools view -i 'INFO/BCSQ!=""' ../../output/PTCL_StructuralVariants_CanFam3.filtered.ann.vcf -o ../../output/PTCL_StructuralVariants_CanFam3.filtered.ann.bcsq.vcf

######## Create vcf file of only breakend variant calls ########
# Of all SVs that passed filtering
bcftools view -i 'INFO/SVTYPE=="BND"' ../../output/PTCL_StructuralVariants_CanFam3.filtered.ann.vcf -o ../../output/PTCL_BND_Variants.filtered.ann.vcf
# Of only SVs that impact genes
bcftools view -i 'INFO/SVTYPE=="BND"' ../../output/PTCL_StructuralVariants_CanFam3.filtered.ann.bcsq.vcf -o ../../output/PTCL_BND_Variants.filtered.ann.bcsq.vcf
