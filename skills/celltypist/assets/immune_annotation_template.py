#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
CellTypist Immune Cell Annotation Template

Complete workflow for annotating scRNA-seq data with immune cell types.
Copy and customize this template for your analysis.

Based on: https://github.com/Teichlab/celltypist
"""

import scanpy as sc
import celltypist
from celltypist import models

# =============================================================================
# Configuration - Customize these parameters
# =============================================================================

INPUT_FILE = 'your_data.h5ad'
OUTPUT_FILE = 'annotated_data.h5ad'
MODEL_NAME = 'Immune_All_Low.pkl'  # Or 'Immune_All_High.pkl' for major types
USE_MAJORITY_VOTING = True  # Recommended for better accuracy
EXISTING_ANNOTATION_COL = None  # Set to column name if you have existing annotations to compare

# =============================================================================
# Step 1: Download/Update Models (first time only)
# =============================================================================

# Download all available models (recommended)
# models.download_models()

# Or download specific model
models.download_models(model=MODEL_NAME)

# View all available models
print("Available models:")
models.models_description()

# =============================================================================
# Step 2: Load Data
# =============================================================================

print(f"\nLoading data from: {INPUT_FILE}")
adata = sc.read_h5ad(INPUT_FILE)
print(f"Shape: {adata.shape[0]} cells × {adata.shape[1]} genes")

# Verify data is properly normalized (log1p to 10,000 counts per cell)
print("\nChecking normalization...")
totals = adata.X.expm1().sum(axis=1)
print(f"Mean total counts after expm1: {totals.mean():.0f} (should be ~10000)")

# =============================================================================
# Step 3: Inspect Model
# =============================================================================

print(f"\nLoading model: {MODEL_NAME}")
model = models.Model.load(model=MODEL_NAME)
print(model)
print(f"\nCell types in model ({len(model.cell_types)}):")
for ct in sorted(model.cell_types)[:20]:  # Show first 20
    print(f"  - {ct}")
if len(model.cell_types) > 20:
    print(f"  ... and {len(model.cell_types) - 20} more")

# =============================================================================
# Step 4: Run Cell Type Annotation
# =============================================================================

print(f"\nAnnotating cells with majority_voting={USE_MAJORITY_VOTING}...")
predictions = celltypist.annotate(
    adata,
    model=MODEL_NAME,
    majority_voting=USE_MAJORITY_VOTING
)

# View prediction results
print("\nPrediction results:")
print(predictions.predicted_labels)

# =============================================================================
# Step 5: Integrate Results into AnnData
# =============================================================================

# Convert to AnnData with predictions
adata = predictions.to_adata(
    insert_labels=True,   # Add 'predicted_labels' to obs
    insert_conf=True,     # Add 'conf_score' to obs
    insert_prob=False     # Set True to add probability matrix
)

# View new columns
print("\nNew metadata columns:")
print(adata.obs.columns.tolist())

# =============================================================================
# Step 6: Visualization
# =============================================================================

# Compute UMAP if not already present
if 'X_umap' not in adata.obsm:
    print("\nComputing UMAP...")
    if 'X_pca' not in adata.obsm:
        sc.pp.pca(adata)
    sc.pp.neighbors(adata)
    sc.tl.umap(adata)

# Set up plotting
sc.settings.set_figure_params(dpi=100, frameon=False)

# Plot predictions on UMAP
label_col = 'majority_voting' if USE_MAJORITY_VOTING else 'predicted_labels'
cols_to_plot = [label_col, 'conf_score']

if EXISTING_ANNOTATION_COL and EXISTING_ANNOTATION_COL in adata.obs.columns:
    cols_to_plot.insert(0, EXISTING_ANNOTATION_COL)

print(f"\nGenerating UMAP plots for: {cols_to_plot}")
sc.pl.umap(adata, color=cols_to_plot, legend_loc='on data')

# Compare with existing annotations if available
if EXISTING_ANNOTATION_COL and EXISTING_ANNOTATION_COL in adata.obs.columns:
    print(f"\nComparing CellTypist predictions with {EXISTING_ANNOTATION_COL}...")
    celltypist.dotplot(
        predictions,
        use_as_reference=EXISTING_ANNOTATION_COL,
        use_as_prediction=label_col
    )

# =============================================================================
# Step 7: Examine Marker Genes (Optional)
# =============================================================================

# Extract top marker genes for a cell type of interest
CELL_TYPE_OF_INTEREST = "CD8-positive, alpha-beta T cell"  # Customize this

if CELL_TYPE_OF_INTEREST in model.cell_types:
    print(f"\nTop marker genes for {CELL_TYPE_OF_INTEREST}:")
    top_markers = model.extract_top_markers(CELL_TYPE_OF_INTEREST, 10)
    print(top_markers)
    
    # Visualize marker expression
    sc.pl.violin(adata, top_markers[:5], groupby=label_col, rotation=90)

# =============================================================================
# Step 8: Save Results
# =============================================================================

print(f"\nSaving annotated data to: {OUTPUT_FILE}")
adata.write(OUTPUT_FILE)

# Print summary
print("\n" + "="*60)
print("ANNOTATION COMPLETE")
print("="*60)
print(f"Output file: {OUTPUT_FILE}")
print(f"\nCell type distribution ({label_col}):")
for ct, count in adata.obs[label_col].value_counts().head(15).items():
    pct = 100 * count / adata.n_obs
    print(f"  {ct}: {count} ({pct:.1f}%)")
