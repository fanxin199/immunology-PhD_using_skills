# spatial-transcriptomics

## Overview

Analyze spatial transcriptomics data from Visium, Xenium, MERFISH, Slide-seq, Stereo-seq, and related platforms using one guided workflow.

**Tool type:** python | **Primary tools:** Squidpy, SpatialData, Scanpy, scimap

## Covers

- Data loading and platform-aware setup
- QC, normalization, and feature selection
- Spatial neighbor graphs and connectivity
- Spatial autocorrelation, co-occurrence, and enrichment
- Spatial domains and tissue-region analysis
- Publication-ready visualization
- Optional communication and deconvolution analyses

## Example Prompts

- "Load my Visium data"
- "Read this Xenium output folder"
- "Run QC on my spatial data"
- "Normalize my spatial transcriptomics data"
- "Build a spatial neighbor graph with 6 neighbors"
- "Calculate Moran's I for this gene"
- "Find spatially variable genes"
- "Identify spatial domains in my tissue"
- "Plot gene expression on the tissue"
- "Show clusters overlaid on the image"
- "Run ligand-receptor analysis"
- "Deconvolve my Visium data with cell2location"

## Requirements

```bash
pip install squidpy spatialdata spatialdata-io scanpy anndata scimap
```

## Related Skills

- **squidpy-spatial-viz** - publication-grade spatial figures
- **single-cell** - non-spatial scRNA-seq analysis
- **data-visualization** - visualization polish and layout
