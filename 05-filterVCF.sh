#!/bin/bash

# Remove variants that failed pbsv filters
bcftools view -i 'FILTER="PASS"' ../output/ptcl_large_structural_variants_ccs.vcf > ../output/ptcl_large_structural_variants_ccs.pass.vcf

# Create vcf file of only breakend variant calls
bcftools view -i 'INFO/SVTYPE=="BND"' ../output/ptcl_large_structural_variants_ccs.pass.vcf > ../output/ptcl_BND_variants_ccs.pass.vcf
