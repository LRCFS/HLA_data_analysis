# HLA_data_analysis

## Quickstart



## Prerequisites

The following tools are required.

    BBMap from [BBTools](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/)
    Samtools
    Picard
    BWA
    [Jvarkit](https://jvarkit.readthedocs.io/en/latest/)
    Snakemake 

## Details




### Footnotes

FASTQ reads in this repo were generated synthetically with [ArtificialFastqGenerator](https://github.com/mframpton/ArtificialFastqGenerator) to avoid using human identifiable data.

This was the command used to generate read data from the [HLA-A](https://www.ensembl.org/Homo_sapiens/Gene/Summary?db=core;g=ENSG00000206503) Ensembl gene reference sequence.

    java -jar ArtificialFastqGenerator.jar -R Homo_sapiens_HLA_A_sequence.fa -O HLA -S ">6" -TLSD 10 -X 10 -RL 100 -TLM 300  -URQS true -SE true -F1 test1.fastq -F2 test2.fastq


