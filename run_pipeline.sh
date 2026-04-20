#!/bin/bash
set -euo pipefail
REFERENCE='reference/GRCh38.fa'
KNOWN_SITES='reference/dbsnp_146.hg38.vcf.gz'
THREADS=8
OUTDIR='results'
mkdir -p ${OUTDIR}/{qc,aligned,variants,annotated}
for R1 in data/*_R1.fastq.gz; do
    SAMPLE=$(basename ${R1} _R1.fastq.gz)
    R2=${R1/_R1/_R2}
    fastqc -t ${THREADS} -o ${OUTDIR}/qc ${R1} ${R2}
    bwa-mem2 mem -t ${THREADS} -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA" ${REFERENCE} ${R1} ${R2} | samtools sort -@ ${THREADS} -o ${OUTDIR}/aligned/${SAMPLE}.sorted.bam
    samtools index ${OUTDIR}/aligned/${SAMPLE}.sorted.bam
    gatk MarkDuplicates -I ${OUTDIR}/aligned/${SAMPLE}.sorted.bam -O ${OUTDIR}/aligned/${SAMPLE}.dedup.bam -M ${OUTDIR}/aligned/${SAMPLE}.dup_metrics.txt
    gatk BaseRecalibrator -I ${OUTDIR}/aligned/${SAMPLE}.dedup.bam -R ${REFERENCE} --known-sites ${KNOWN_SITES} -O ${OUTDIR}/aligned/${SAMPLE}.recal_table
    gatk ApplyBQSR -I ${OUTDIR}/aligned/${SAMPLE}.dedup.bam -R ${REFERENCE} --bqsr-recal-file ${OUTDIR}/aligned/${SAMPLE}.recal_table -O ${OUTDIR}/aligned/${SAMPLE}.recal.bam
    gatk HaplotypeCaller -I ${OUTDIR}/aligned/${SAMPLE}.recal.bam -R ${REFERENCE} -ERC GVCF -O ${OUTDIR}/variants/${SAMPLE}.g.vcf.gz
done
echo 'Pipeline complete.'
