---
name: spatial-transcriptomics
description: End-to-end spatial transcriptomics workflow hub (Visium/Xenium/MERFISH/Slide-seq/etc.) using Squidpy/SpatialData/Scanpy. Covers loading, QC/normalization, spatial graphs, spatial statistics, domains, visualization, cell-cell communication, and deconvolution.
---

# Spatial Transcriptomics (Workflow Hub)

This skill is an umbrella entrypoint for spatial transcriptomics analysis and reporting.

It pairs well with:
- `scvi-tools` (probabilistic models / integration)
- `squidpy-spatial-viz` (publication-grade spatial figures)
- `scientific-visualization` (export/layout conventions)

## Included Modules

This folder bundles focused submodules (each has its own `SKILL.md` and examples):

| Module folder | Focus |
|---|---|
| `spatial-data-io/` | Load Visium/Xenium/MERFISH/Slide-seq outputs and coordinates |
| `spatial-preprocessing/` | QC, filtering, normalization, feature selection |
| `spatial-neighbors/` | Build spatial neighbor graphs (kNN/radius/Delaunay) |
| `spatial-statistics/` | Moran's I / autocorrelation / co-occurrence / enrichment |
| `spatial-domains/` | Spatial domains / tissue regions |
| `spatial-visualization/` | Spatial scatter, tissue overlay, feature maps |
| `image-analysis/` | Tissue image processing and feature extraction |
| `spatial-communication/` | Ligand-receptor / spatial communication (Squidpy) |
| `spatial-deconvolution/` | Reference-based deconvolution (cell2location/RCTD/etc.) |
| `spatial-multiomics/` | High-resolution platforms (Visium HD / Stereo-seq / Slide-seq) |
| `spatial-proteomics/` | Spatial proteomics (CODEX/IMC/MIBI) |

## Quick Start (Typical Visium Flow)

1) Load data (Space Ranger output)
2) QC + normalization
3) Spatial neighbors graph
4) Spatial stats (optional) and/or domains (optional)
5) Publication figures (overlay + feature maps)

When you ask for spatial analysis, include:
- platform (Visium/Xenium/MERFISH/etc.)
- inputs you have (counts, positions, images, h5ad)
- your goal (QC, domains, deconvolution, spatial DE, communication)
