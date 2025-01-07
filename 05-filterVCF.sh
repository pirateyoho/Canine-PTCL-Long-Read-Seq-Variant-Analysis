#!/bin/bash

# Remove variants that failed pbsv filters
bcftools view -i 'FILTER="PASS"' ../output/PTCL_StructuralVariants_CanFam3.vcf.vcf > ../output/PTCL_StructuralVariants_CanFam3.vcf.pass.vcf

# Create vcf file of only breakend variant calls
bcftools view -i 'INFO/SVTYPE=="BND"' ../output/PTCL_StructuralVariants_CanFam3.vcf.pass.vcf > ../output/PTCL_BND_Variants.pass.vcf
