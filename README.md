# GATK Variant Calling Pipeline

> From raw FASTQ files to annotated variants. This is the pipeline that clinical labs and research groups actually use, and understanding it end-to-end is non-negotiable if you work in genomics.

## Why You Need to Understand This Pipeline

Every time a patient gets whole-genome sequencing, every time a cancer sample is profiled for actionable mutations, some version of this pipeline is running behind the scenes. GATK's Best Practices is the de facto standard for germline variant calling.

## What Each Step Does and Why It Matters

**1. Quality Control (FastQC + MultiQC)**: Before you do anything, look at your data. Catching problems here saves you from chasing artefacts through every downstream step.

**2. Alignment (BWA-MEM2)**: Your reads need to be placed on the reference genome. The read group information you add here is critical. Miss this, and GATK will refuse to run.

**3. Duplicate Marking**: PCR duplicates don't represent independent observations and will inflate your confidence in false variants if you don't mark them.

**4. BQSR**: The quality scores from the sequencer are often wrong. BQSR recalibrates them using known variant sites, directly impacting your variant quality.

**5. HaplotypeCaller (GVCF Mode)**: This is where variants are called. HaplotypeCaller performs local de novo assembly of haplotypes, which is why it's better than simple pileup-based callers.

**6. Joint Genotyping**: Genotype all samples together to borrow statistical strength across the cohort.

**7. Variant Filtration**: Hard filters remove likely artefacts based on mapping quality, strand bias, and other metrics.

**8. Annotation (SnpEff)**: A VCF of coordinates isn't useful until you know what the variants do. SnpEff tells you missense vs. synonymous vs. intronic.

## Common Mistakes That Will Cost You Hours

- **Forgetting read groups**: GATK will error out.
- **Using VQSR with fewer than 30 samples**: Use hard filters instead.
- **Skipping BQSR**: Your variant quality scores will be miscalibrated.

## Usage
```bash
bash run_pipeline.sh config.yaml
```
