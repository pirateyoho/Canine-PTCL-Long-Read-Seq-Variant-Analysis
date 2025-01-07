#!/bin/bash

#SBATCH --job-name=pbsv_call
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --time=5:00:00
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT
#SBATCH --mail-user=edlarsen@colostate.edu
#SBATCH --output=pbsv_call_ccs_log_%j.txt


# Print pbsv version
pbsv --version

# get list of svsig.gz files
infiles=$(ls ../output/*.svsig.gz)

# Run pbsv call jointly for all samples of interest
pbsv call --ccs Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa ${infiles} ../output/PTCL_StructuralVariants_CanFam3.vcf
