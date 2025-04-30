#!/bin/bash

#SBATCH --job-name=PacBioSV
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --time=23:55:00
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT
#SBATCH --mail-user=edlarsen@colostate.edu
#SBATCH --output=PacBioSV_log_%j.txt

# Conda environment with pbmm2, pbsv, bcftools, and pysam (a depdendency of svpack) should be activated prior to running

# Print versions
pbmm2 --version
pbsv --version
bcftools --version

##################################################
##### DOWNLOAD REFERENCE GENOME FASTA FILES #####
##################################################
# CanFam3.1
rsync -azvP rsync://ftp.ensembl.org/ensembl/pub/release-104/fasta/canis_lupus_familiaris/dna/Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa.gz .
# CanFam4
rsync -azvP rsync://ftp.ensembl.org/ensembl/pub/release-109/fasta/canis_lupus_familiarisgsd/dna/Canis_lupus_familiarisgsd.UU_Cfam_GSD_1.0.dna.toplevel.fa.gz .

# Check md5sum of FASTA files
rsync -avzP rsync://ftp.ensembl.org/ensembl/pub/release-104/fasta/canis_lupus_familiaris/dna/CHECKSUMS .
grep ".dna.toplevel" CHECKSUMS
sum Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa.gz

rsync -avzP rsync://ftp.ensembl.org/ensembl/pub/release-109/fasta/canis_lupus_familiarisgsd/dna/CHECKSUMS .
grep ".dna.toplevel" CHECKSUMS
sum Canis_lupus_familiarisgsd.UU_Cfam_GSD_1.0.dna.toplevel.fa.gz

# Extract compressed FASTA files
gunzip Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa.gz
gunzip Canis_lupus_familiarisgsd.UU_Cfam_GSD_1.0.dna.toplevel.fa.gz

############################################################
##### ALIGN HIFI READS TO REFERENCE GENOME WITH PBMM2 #####
############################################################
# Create reference genome index
pbmm2 index Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa CanFam31.mmi --preset HIFI
pbmm2 index Canis_lupus_familiarisgsd.UU_Cfam_GSD_1.0.dna.toplevel.fa CanFam4.mmi --preset HIFI

# Align HiFi reads
infiles="../data/EO-125_CH149695-CH166393_Pooled_HiFi_300pM-Cell7/6722_import-dataset/hifi_reads/m84082_241212_212355_s1.hifi_reads.bc2013.bam ../data/EO-125_CH152139-CH152256_Pooled_HiFi_300pM-Cell8/6721_import-dataset/hifi_reads/m84082_241212_232319_s2.hifi_reads.bc2014.bam ../data/EO-125_CH152139-CH152256_Pooled_HiFi_300pM-Cell8/6721_import-dataset/hifi_reads/m84082_241212_232319_s2.hifi_reads.bc2015.bam ../data/EO-125_CH154958-CH154980_Pooled_HiFi_300pM-Cell2/6724_import-dataset/hifi_reads/m84082_241218_023253_s2.hifi_reads.bc2016.bam ../data/EO-125_CH154958-CH154980_Pooled_HiFi_300pM-Cell2/6724_import-dataset/hifi_reads/m84082_241218_023253_s2.hifi_reads.bc2017.bam ../data/EO-125_CH149695-CH166393_Pooled_HiFi_300pM-Cell7/6722_import-dataset/hifi_reads/m84082_241212_212355_s1.hifi_reads.bc2018.bam"

for file in $infiles
do
name=$(basename "${file}" | awk -F'.' '{print $(NF-1)}'); echo ${name}
pbmm2 align CanFam31.mmi ${file} ../output/${name}.CanFam3.aligned.bam --preset HIFI --sort --j 16 -J 8 --log-level INFO --sample ${name}
pbmm2 align CanFam4.mmi ${file} ../output/${name}.CanFam4.aligned.bam --preset HIFI --sort --j 16 -J 8 --log-level INFO --sample ${name}
done

echo "pbmm2 steps completed"

###############################################
##### CALL STRUCTURAL VARIANTS WITH PBSV #####
###############################################
# Acquire bed file of tandem repeat locations for reference genome
wget --timestamping 'ftp://hgdownload.cse.ucsc.edu/goldenPath/canFam3/bigZips/canFam3.trf.bed.gz'
gunzip canFam3.trf.bed.gz
wget --timestamping 'ftp://hgdownload.cse.ucsc.edu/goldenPath/canFam4/bigZips/canFam4.trf.bed.gz'
gunzip canFam4.trf.bed.gz

# Discover signatures of structural variation
for file in $(ls ../output/*.CanFam3.aligned.bam)
do
name=$(basename ${file} .aligned.bam); echo ${name}
pbsv discover --tandem-repeats canFam3.trf.bed  ${file} ../output/${name}.svsig.gz
done

for file in $(ls ../output/*.CanFam4.aligned.bam)
do
name=$(basename ${file} .aligned.bam); echo ${name}
pbsv discover --tandem-repeats canFam4.trf.bed ${file} ../output/${name}.svsig.gz
done

# Call structural variants and assign genotypes
# get list of svsig.gz files
Cfam3_infiles=$(ls ../output/*.CanFam3.svsig.gz)
Cfam4_infiles=$(ls ../output/*.CanFam4.svsig.gz)

# Run pbsv call jointly for all samples of interest
pbsv call --ccs Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa ${Cfam3_infiles} ../output/PTCL_StructuralVariants_CanFam3.vcf
pbsv call --ccs Canis_lupus_familiarisgsd.UU_Cfam_GSD_1.0.dna.toplevel.fa ${Cfam4_infiles} ../output/PTCL_StructuralVariants_CanFam4.vcf

echo "pbsv steps completed"

############################################
##### FILTER & ANNOTATE VARIANT CALLS #####
###########################################
# install svpack
git clone https://github.com/PacificBiosciences/svpack.git
cd svpack

# Return PASS SVs at least 50 bp long
./svpack filter --pass-only --min-svlen 50 ../../output/PTCL_StructuralVariants_CanFam3.vcf > ../../output/PTCL_StructuralVariants_CanFam3.filtered.vcf
./svpack filter --pass-only --min-svlen 50 ../../output/PTCL_StructuralVariants_CanFam4.vcf > ../../output/PTCL_StructuralVariants_CanFam4.filtered.vcf

### Annotate SVs that impact genes
## Retrieve gff3 files for reference genomes
# CanFam3.1
rsync -azvP rsync://ftp.ensembl.org/ensembl/pub/release-104/gff3/canis_lupus_familiaris/Canis_lupus_familiaris.CanFam3.1.104.gff3.gz .
# CanFam 4
rsync -azvP rsync://ftp.ensembl.org/ensembl/pub/release-109/gff3/canis_lupus_familiarisgsd/Canis_lupus_familiarisgsd.UU_Cfam_GSD_1.0.109.gff3.gz .

# Check md5sum
rsync -azvP rsync://ftp.ensembl.org/ensembl/pub/release-104/gff3/canis_lupus_familiaris/CHECKSUMS .
grep "CanFam3.1.104.gff3.gz" CHECKSUMS
sum Canis_lupus_familiaris.CanFam3.1.104.gff3.gz

rsync -azvP rsync://ftp.ensembl.org/ensembl/pub/release-109/gff3/canis_lupus_familiarisgsd/CHECKSUMS .
grep "1.0.109.gff3.gz" CHECKSUMS
sum Canis_lupus_familiarisgsd.UU_Cfam_GSD_1.0.109.gff3.gz

# Extract compressed gff3 files
gunzip Canis_lupus_familiaris.CanFam3.1.104.gff3.gz
gunzip Canis_lupus_familiarisgsd.UU_Cfam_GSD_1.0.109.gff3.gz

## Add BCSQ tag to variants that impact genes
./svpack consequence ../../output/PTCL_StructuralVariants_CanFam3.filtered.vcf Canis_lupus_familiaris.CanFam3.1.104.gff3 > ../../output/PTCL_StructuralVariants_CanFam3.filtered.ann.vcf

./svpack consequence ../../output/PTCL_StructuralVariants_CanFam4.filtered.vcf Canis_lupus_familiarisgsd.UU_Cfam_GSD_1.0.109.gff3 > ../../output/PTCL_StructuralVariants_CanFam4.filtered.ann.vcf

## Subset only SVs that impact genes
bcftools view -i 'INFO/BCSQ!=""' ../../output/PTCL_StructuralVariants_CanFam3.filtered.ann.vcf -o ../../output/PTCL_StructuralVariants_CanFam3.filtered.ann.bcsq.vcf
bcftools view -i 'INFO/BCSQ!=""' ../../output/PTCL_StructuralVariants_CanFam4.filtered.ann.vcf -o ../../output/PTCL_StructuralVariants_CanFam4.filtered.ann.bcsq.vcf

## Subset only breakend variant calls
# Of all BND that passed filtering
bcftools view -i 'INFO/SVTYPE=="BND"' ../../output/PTCL_StructuralVariants_CanFam3.filtered.ann.vcf -o ../../output/PTCL_BND_Variants.CanFam3.filtered.ann.vcf
bcftools view -i 'INFO/SVTYPE=="BND"' ../../output/PTCL_StructuralVariants_CanFam4.filtered.ann.vcf -o ../../output/PTCL_BND_Variants.CanFam4.filtered.ann.vcf
# Of only BND that impact genes
bcftools view -i 'INFO/SVTYPE=="BND"' ../../output/PTCL_StructuralVariants_CanFam3.filtered.ann.bcsq.vcf -o ../../output/PTCL_BND_Variants.CanFam3.filtered.ann.bcsq.vcf
bcftools view -i 'INFO/SVTYPE=="BND"' ../../output/PTCL_StructuralVariants_CanFam4.filtered.ann.bcsq.vcf -o ../../output/PTCL_BND_Variants.CanFam4.filtered.ann.bcsq.vcf
