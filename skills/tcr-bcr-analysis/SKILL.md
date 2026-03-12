---
name: tcr-bcr-analysis
description: Immune repertoire (TCR/BCR) clonotype analysis. Load 10x V(D)J outputs, compute clonal expansion/diversity/overlap, and integrate clonotypes into AnnData for downstream scRNA workflows.
license: MIT license
metadata:
    skill-author: Local (user-curated)
---

# TCR/BCR clonotype analysis

## Overview

This skill covers practical analysis of immune repertoire sequencing (TCR and BCR), including clonotype assignment, clonal expansion metrics, diversity metrics, overlap between samples/conditions, and integration with single-cell RNA-seq via AnnData.

It is designed to work with common outputs from 10x Genomics V(D)J pipelines (Cell Ranger / Cell Ranger ARC) and with generic clonotype tables.

## When to Use This Skill

Use this skill when you need to:
- Analyze **TCR/BCR clonotypes** (CDR3 sequences, V/J genes, clonotype IDs)
- Quantify **clonal expansion** and compare expansion across conditions
- Compute repertoire **diversity** (Shannon/Simpson), **evenness**, and **Gini**-like inequality
- Measure **clonotype overlap** across samples or tissues (Jaccard/Morisita-Horn)
- Integrate V(D)J-derived clonotypes into **scRNA AnnData** for joint visualization

## Typical Inputs

Common file types you may have:
- 10x V(D)J contigs: `filtered_contig_annotations.csv` / `all_contig_annotations.csv`
- 10x clonotypes summary: `clonotypes.csv`
- Per-cell clonotype table (custom)
- Optional: paired scRNA object (`.h5ad`) with cell barcodes

### Key join rule

10x barcodes in V(D)J outputs typically look like `AAAC...-1`. Ensure barcode suffixes match your scRNA object (some pipelines remove `-1`). Normalize barcodes before merging.

## Recommended Tooling

### Preferred (if installed)

- **scirpy** (built on scanpy/anndata) for single-cell immune repertoire workflows.

### Always available fallback

- **pandas + numpy** for table operations
- **scanpy/anndata** to store clonotype annotations in `adata.obs` and visualize on UMAP

## Core Workflows

### 1) Basic clonotype summary

Compute per-sample clonotype counts, top expanded clones, and clone size distribution.

Outputs to report:
- number of cells with a productive chain
- number of unique clonotypes
- top N clonotypes by cell count
- clone size histogram (optionally log-scaled)

### 2) Diversity metrics

Common metrics:
- Shannon diversity (H)
- Simpson diversity (1 - D) or inverse Simpson
- Pielou evenness (H / log(S))

Compute per sample and per group (e.g., tissue, treatment).

### 3) Clonal expansion comparisons

Compare clone size distributions across conditions:
- fraction of cells in expanded clones (e.g., size ≥ 2/5/10)
- median clone size among clonotyped cells
- differential expansion of specific clonotypes (where appropriate)

### 4) Overlap across samples

Use overlap indices for clonotype sets between samples:
- Jaccard (set overlap)
- Morisita-Horn (abundance-weighted)

Define clonotype identity consistently (e.g., `cdr3_aa + v_gene + j_gene`, or `clonotype_id`).

### 5) Integrate into AnnData

Add these fields into `adata.obs`:
- `has_tcr` / `has_bcr`
- `clonotype_id`
- `clone_size`
- `cdr3_aa` (or `cdr3a`/`cdr3b` for TCR)
- `v_gene`, `j_gene`

Then visualize:
- UMAP colored by `clone_size`
- UMAP highlighting top expanded clones
- clonotype expansion stratified by clusters/cell types

## Notes for TCR vs BCR

- **TCR**: typically alpha/beta (TRA/TRB) or gamma/delta (TRG/TRD). Pay attention to paired chains.
- **BCR**: heavy/light chains (IGH + IGK/IGL). Somatic hypermutation and isotype class switching may require additional annotations beyond basic clonotype calls.

## Deliverables Checklist

When asked to analyze a repertoire dataset, aim to produce:
- Summary table per sample (cells, clonotyped cells, unique clonotypes, diversity)
- Expanded clone fractions (≥2, ≥5, ≥10)
- Overlap matrix between samples
- AnnData with clonotype annotations merged (if scRNA is provided)
