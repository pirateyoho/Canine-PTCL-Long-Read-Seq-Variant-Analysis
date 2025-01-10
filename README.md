# Canine-PTCL-Long-Read-Seq-Variant-Analysis
## Background
This repository contains scripts that were used for calling large structural variants in PacBio HiFi long-read sequencing of DNA from caine periphreal T-cell lymphoma (PTLC) samples. This repository is intended for internal use by members of the Clinical Hematopathology Laboratory at Colorado State University and their collaborators. 
## References
Adapted from the pbmm2 (https://github.com/PacificBiosciences/pbmm2) and pbsv (https://github.com/PacificBiosciences/pbsv) documentation.
## Raw data
This pipeline utilized bam files of PacBio Hifi long-read sequencing data from 6 canine PTCL samples. This data is available from the Avery lab Nas shared drive:
"M:\CHLab data\Sequencing Data\250102_CD4PTCL_PacBioLongReadSeq_Owens"
## Software
A conda (version 23.7.4) environment containing the following packages:
* pbmm2 version 1.14.99
* pbsv version 2.9.0
* bcftools version 1.21
* pysam version 0.22.1
## Pipeline overview
1. Download reference genome FASTA files for CanFam3.1 and CanFam4 from Ensembl.
2. Build an index of the reference genome with *pbmm2 index*.
3. Align HiFi reads to reference genome with *pbmm2 align*.
4. Identify signatures of structural variation with *pbsv discover*.
5. Call structural variants from structural variant signatures and assigns genotypes with *pbsv call*.
6. Filter and annotate variant calls with *svpack* and *bcftools*.
7. Final output: Filtered and annotated structural variant VCF files.
### Sample information
| **Sample #**| **Barcode** | **Sex**| **Breed** | **Tissue** | **Age (yrs.)**| **Barcode Quality**| **HiFi Reads** | **HiFi Yield (GB)**| **HiFi Read Length (mean, bp)** | **HiFi Read Quality (median, QV)**|
|:-----------:|:-----------:|:------:|:---------:|:----------:|:-------------:|:------------------:|:--------------:|:------------------:|:-------------------------------:|:---------------------------------:|
| 152139      | bc2014      | MC     | SPRSP     | Lymph node | 6             | 97.1               | 3,735,101      | 28.0               | 7,507                           | Q37                               |
| 152256      | bc2015      | MC     | HUS       | Lymph node | 4             | 96.9               | 3,474,221      | 23.1               | 6,660                           | Q38                               |
| 149695      | bc2013      | FS     | OESD      | Lymph node | 4             | 96.9               | 5,733,070      | 32.2               | 5,614                           | Q40                               |
| 166393      | bc2018      | MC     | BOX       | Lymph node | 7             | 97.4               | 3,766,001      | 25.0               | 6,639                           | Q39                               |
| 154958      | bc2016      | MC     | MIX       | Lymph node | 8             | 96.9               | 3,833,417      | 26.8               | 6,989                           | Q37                               |
| 154980      | bc2017      | MC     | SHTZ      | Lymph node | 9             | 97                 | 3,715,223      | 28.0               | 7,553                           | Q37                               |
