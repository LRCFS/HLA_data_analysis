#! /bin/sh

# input file
bam=$1
# output file
fasta=$2

# extract forward and reverse reads
samtools fasta -F 0x10 ${bam} > ${fasta}.fwd
samtools fasta -f 0x10 ${bam} > ${fasta}.rev

# make reverse complement of reverse-strand reads
perl -lne 'if (/^>/) { print } else { $rev = reverse $_; $rev =~ tr/ACGT/TGCA/; print $rev }' ${fasta}.rev > ${fasta}.rev2

# merge
cat ${fasta}.fwd ${fasta}.rev2 > ${fasta}

# remove temporary files
rm -f ${fasta}.fwd ${fasta}.rev ${fasta}.rev2
