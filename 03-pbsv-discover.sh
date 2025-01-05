#!/bin/bash

#SBATCH --job-name=pbsv_discover
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --time=23:00:00
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT
#SBATCH --mail-user=edlarsen@colostate.edu
#SBATCH --output=pbsv_discover_log_%j.txt


# Print pbsv version
pbsv --version

for file in $(ls ../output/*.aligned.bam)
do
name=$(basename ${file} .aligned.bam); echo ${name}
pbsv discover ${file} ../output/${name}.svsig.gz
done
