---
name: go-enrichment
description: Gene Ontology (GO) enrichment for immunology. Supports ORA (over-representation) and GSEA-style ranked enrichment, with practical guidance on background sets, ID mapping, and multiple testing.
license: MIT license
metadata:
    skill-author: Local (user-curated)
---

# GO enrichment

## Overview

GO enrichment summarizes gene lists into interpretable biological themes using Gene Ontology terms.

In immunology, GO is frequently used to interpret:
- activation and differentiation programs (T cell activation, leukocyte migration)
- cytokine responses (type I/II interferon signaling)
- antigen processing/presentation
- innate immune sensing and inflammatory signaling

This skill covers two mainstream approaches:
- **ORA**: Over-representation analysis on a discrete gene list (e.g., DEGs, marker genes)
- **Ranked/GSEA-style**: Enrichment on a ranked list (e.g., log2FC, signed -log10(p))

## When to Use

Use this skill when you have:
- Bulk RNA-seq DEGs (up/down separately or combined)
- scRNA-seq cluster marker genes
- module genes (WGCNA / NMF / signatures)
- ranked genes from differential testing

## Inputs

Minimum:
- A list of genes (symbols or Ensembl IDs)

Recommended metadata:
- Organism (human `9606`, mouse `10090`)
- Universe/background gene set (see below)
- For ranked enrichment: a ranked vector over many genes

## Critical Choices (Most Common Failure Modes)

### 1) Background (universe) matters

- **Bulk RNA-seq**: use all genes tested in DE (after filtering) as background.
- **scRNA markers**: use genes expressed/tested in that dataset, not the whole genome.
- Using an incorrect background can create misleading immune-related terms.

### 2) Multiple testing

Always report **FDR** (BH) and avoid interpreting raw p-values.

### 3) Redundancy

GO terms are hierarchical and redundant. Plan to:
- filter by term size
- collapse similar terms (semantic similarity or parent-child pruning)

## Recommended Libraries (Python)

Depending on availability:
- **gseapy**: convenient ORA (Enrichr) and prerank GSEA workflows
- **goatools**: local GO DAG + gene2go based ORA (offline-capable if files are available)
- **g:Profiler** (optional): web-based enrichment with strong ID mapping (needs network)

## Workflow A: ORA (over-representation)

### A1) Split up/down genes (recommended for DE)

- Run GO enrichment separately for upregulated and downregulated genes.
- Use consistent background and parameters.

### A2) Typical outputs

- GO ID, term name
- ontology: BP/MF/CC
- overlap counts (hits / term size)
- p-value and FDR

## Workflow B: Ranked/GSEA-style enrichment

### B1) Create a ranked list

Examples:
- `rank = log2FC` (optionally filter by mean expression)
- `rank = sign(log2FC) * -log10(pvalue)`

### B2) Run preranked enrichment

Prefer prerank when you want to avoid arbitrary DEG thresholds.

## Minimal Python Patterns

### 1) ORA with gseapy (Enrichr)

```python
import gseapy as gp

genes = ["IL7R", "CXCR5", "PDCD1", "CTLA4", "LAG3", "IFNG", "GZMB"]

enr = gp.enrichr(
    gene_list=genes,
    gene_sets=["GO_Biological_Process_2023"],
    organism="Human",
    outdir=None,
)
print(enr.results.head())
```

### 2) Prerank with gseapy

```python
import pandas as pd
import gseapy as gp

# ranks: a two-column df with gene and rank
ranks = pd.DataFrame({
    "gene": ["IL7R", "CXCR5", "PDCD1", "CTLA4"],
    "score": [2.1, 1.7, -1.2, -0.8],
}).sort_values("score", ascending=False)

pre = gp.prerank(
    rnk=ranks,
    gene_sets=["GO_Biological_Process_2023"],
    outdir=None,
    min_size=10,
    max_size=500,
)
print(pre.res2d.head())
```

## Practical Immunology Defaults

- Focus first on **GO:BP**; use GO:CC/MF when needed.
- Filter terms by size (e.g., 10–500 genes) to avoid tiny/noisy and huge/non-specific terms.
- For scRNA clusters: run per cluster, then compare top terms across clusters.

## Integration Tips

- Combine with `reactome-database/` for curated pathway interpretation.
- Use `string-database/` enrichment for fast GO/KEGG/Reactome summaries when you also want interaction context.
- Normalize identifiers with `uniprot-database/` when symbols are ambiguous.
