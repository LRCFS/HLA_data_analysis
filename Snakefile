
Samples = [
'Sample_L1',
'Sample_L2']

rule target:
	input: expand("{sample}.summary.fasta", sample=Samples)

rule help:
  """
  This Snakemake takes raw HLA amplicon Illumina data and returns cleaned FASTA "alleles".
  The following steps are performed - not necessarily in this order:
  """
  run:
    for rule in workflow.rules:
      print( rule.name )
      print( rule.docstring )

rule merge:
	"""
	Take paired-end reads and merge overlaps into single reads
	"""
	input:
		in1 = "{sample}_1.fq.gz",
		in2 = "{sample}_2.fq.gz"
	output:
		out = "{sample}_merge.fq.gz",
		outu = "{sample}_unmerge.fq.gz"
	shell:
		"bbmerge.sh in1={input.in1} in2={input.in2} out={output.out} outu={output.outu}"

rule bwa:
	"""
	Aligned reads with BWA mem
	"""
	input:
		fq="{sample}_merge.fq.gz",
		ref="Hsapiens_chr6_alt_ens98.fa"
	output:
		temp("{sample}.sam")
	threads: 8
	shell:
		"bwa mem -t {threads} {input.ref} {input.fq} > {output}"

rule picard:
	"""
	Create sorted and indexed BAM file from SAM input file.
	"""
	input:
		"{sample}.sam"
	output:
		"{sample}_sort.bam"
	shell:
		"picard SortSam I={input} O={output} SO=coordinate CREATE_INDEX=True"

rule pcrclip:
	"""
	Mark read regions outside of amplicons for clipping.
	"""
	input:
		bam="{sample}_sort.bam",
		bed="HLA-DRB3.bed"
	output:
		temp("{sample}_tmp.bam")
	shell:
		"java -jar pcrclipreads.jar -B {input.bed} {input.bam} | samtools  view  -F 4 -Sb  -  > {output}"

rule rmclip:
	"""
	Remove clipped bases from all reads.
	"""
	input:
		"{sample}_tmp.bam"
	output:
		"{sample}_clip.bam"
	shell:
		"java -jar biostar84452.jar {input} > {output}"

rule tofasta:
	"""
	Output clipped reads as a FASTA file.
	"""
	input:
		"{sample}_clip.bam"
	output:
		"{sample}.fasta"
	shell:
		"bam2fasta.sh {input} {output}"

rule summary:
	"""
	Summarise alleles from FASTA file.
	"""
	input:
		"{sample}.fasta"
	output:
		"{sample}.summary.fasta"
	shell:
		"summarise_alleles.pl --file {input} --out {output}"

