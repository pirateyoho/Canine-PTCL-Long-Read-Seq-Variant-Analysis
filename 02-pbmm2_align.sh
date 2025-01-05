#!/bin/bash

#SBATCH --job-name=pbmm2_align8
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --time=2:00:00
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT
#SBATCH --mail-user=edlarsen@colostate.edu
#SBATCH --output=pbmm2_align_log_%j.txt


# Print pbmm2 version
pbmm2 --version

infiles="../data/EO-125_CH149695-CH166393_Pooled_HiFi_300pM-Cell7/6722_import-dataset/hifi_reads/m84082_241212_212355_s1.hifi_reads.bc2013.bam ../data/EO-125_CH152139-CH152256_Pooled_HiFi_300pM-Cell8/6721_import-dataset/hifi_reads/m84082_241212_232319_s2.hifi_reads.bc2014.bam ../data/EO-125_CH152139-CH152256_Pooled_HiFi_300pM-Cell8/6721_import-dataset/hifi_reads/m84082_241212_232319_s2.hifi_reads.bc2015.bam ../data/EO-125_CH154958-CH154980_Pooled_HiFi_300pM-Cell2/6724_import-dataset/hifi_reads/m84082_241218_023253_s2.hifi_reads.bc2016.bam ../data/EO-125_CH154958-CH154980_Pooled_HiFi_300pM-Cell2/6724_import-dataset/hifi_reads/m84082_241218_023253_s2.hifi_reads.bc2017.bam ../data/EO-125_CH149695-CH166393_Pooled_HiFi_300pM-Cell7/6722_import-dataset/hifi_reads/m84082_241212_212355_s1.hifi_reads.bc2018.bam"

for file in $infiles
do
name=$(basename "${file}" | awk -F'.' '{print $(NF-1)}'); echo ${name}
pbmm2 align --num-threads 24 CanFam31.mmi ${file} ../output/${name}.aligned.bam --preset SUBREAD
done