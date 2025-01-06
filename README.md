# Canine-PTCL-Long-Read-Seq-Variant-Analysis
## Background
This repository contains scripts that were used for calling large structural variants in PacBio HiFi long-read sequencing of DNA from caine periphreal T-cell lymphoma (PTLC) samples. This repository is intended for internal use by members of the Clinical Hematopathology Laboratory at Colorado State University and their collaborators. 


Scripts are numbered in the order they were run. Scripts with the same number were run simultaneously.
## References
These scripts were adapted from the pbmm2 (https://github.com/PacificBiosciences/pbmm2) and pbsv (https://github.com/PacificBiosciences/pbsv) documentation.
## Raw data
This pipeline utilized bam files of PacBio Hifi long-read sequencing data from 6 canine PTCL samples. This data is available from the Avery lab Nas shared drive:
"M:\CHLab data\Sequencing Data\250102_CD4PTCL_PacBioLongReadSeq_Owens"
## Pipeline overview
1. Raw data was transferred from the Nas drive to a scratch directory on CURC Alpine HPC with FileZilla.
2. pbmm2 version 1.14.99 and pbsv version 2.9.0 were installed into a conda environment.
3. Reference genome FASTA files for CanFam3.1 were downloaded from Ensembl.
4. A pbmm2 index was built from the reference genome files.
5. pbmm2 was used to perform alignment of HiFi reads to the reference genome.
6. pbsv discover was used to identify signatures of structural variation.
7. pbsv call was used to call structural variants from structural variant signature and assign genotypes.
### Sample information
| **Sample #**| **Barcode** | **Sex**| **Breed** | **Tissue** | **Age (yrs.)**| **Barcode Quality**| **HiFi Reads** | **HiFi Yield (GB)**| **HiFi Read Length (mean, bp)** | **HiFi Read Quality (median, QV)**|
|:-----------:|:-----------:|:------:|:---------:|:----------:|:-------------:|:------------------:|:--------------:|:------------------:|:-------------------------------:|:---------------------------------:|
| 152139      | bc2014      | MC     | SPRSP     | Lymph node | 6             | 97.1               | 3,735,101      | 28.0               | 7,507                           | Q37                               |
| 152256      | bc2015      | MC     | HUS       | Lymph node | 4             | 96.9               | 3,474,221      | 23.1               | 6,660                           | Q38                               |
| 149695      | bc2013      | FS     | OESD      | Lymph node | 4             | 96.9               | 5,733,070      | 32.2               | 5,614                           | Q40                               |
| 166393      | bc2018      | MC     | BOX       | Lymph node | 7             | 97.4               | 3,766,001      | 25.0               | 6,639                           | Q39                               |
| 154958      | bc2016      | MC     | MIX       | Lymph node | 8             | 96.9               | 3,833,417      | 26.8               | 6,989                           | Q37                               |
| 154980      | bc2017      | MC     | SHTZ      | Lymph node | 9             | 97                 | 3,715,223      | 28.0               | 7,553                           | Q37                               |
