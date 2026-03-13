---
name: spatial-transcriptomics
description: End-to-end spatial transcriptomics analysis skill for Visium/Xenium/MERFISH/Slide-seq and related platforms using Squidpy, SpatialData, and Scanpy. Use for loading data, QC and normalization, spatial neighbor graphs, spatial statistics, domains, visualization, communication analysis, and deconvolution within one guided workflow.
---

# Spatial Transcriptomics

This skill is a single entrypoint for spatial transcriptomics analysis and reporting.

It is designed for users who want one guided workflow covering the common stages of spatial analysis without switching between multiple nested skills.

## Best For

- Loading Visium, Xenium, MERFISH, Slide-seq, Stereo-seq, and related spatial outputs
- QC, filtering, normalization, and feature selection
- Spatial neighbor graphs, autocorrelation, co-occurrence, and enrichment
- Spatial domains, tissue regions, and publication-ready visualization
- Optional communication and deconvolution follow-up analyses

## Typical Workflow

1. Load the spatial dataset and confirm platform-specific inputs.
2. Run QC, filtering, and normalization.
3. Build spatial neighbor graphs.
4. Run spatial statistics and/or domain discovery as needed.
5. Generate publication-ready figures.
6. Add optional communication or deconvolution analysis if the project requires it.

## Ask The User For

- Platform (Visium, Xenium, MERFISH, Slide-seq, Stereo-seq, CODEX, IMC, etc.)
- Available inputs (counts, coordinates, tissue image, h5ad, metadata)
- Main goal (QC, domains, visualization, communication, deconvolution, spatial DE)

## Related Skills

- `squidpy-spatial-viz` for spatial figure polishing
- `scvi-tools` when probabilistic modeling or integration is needed
- `scientific-visualization` when export or figure layout conventions matter
