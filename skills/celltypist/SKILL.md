---
name: celltypist
description: Automated cell type annotation for scRNA-seq using pre-trained immune cell models. Use when annotating cell types, classifying immune cells, predicting cell identities, transferring labels from reference to query data, or when user mentions "celltypist", "cell type annotation", "immune cell classification", "自动注释", "细胞类型注释". Works with AnnData (.h5ad) and integrates with scanpy workflows.
---

# CellTypist: Automated Cell Type Annotation

## Overview

CellTypist is a machine learning-based tool for automated cell type annotation of scRNA-seq data. It uses logistic regression classifiers trained on reference datasets to predict cell identities. Best for immune cell annotation with 20+ pre-trained models.

## Quick Start

```python
import celltypist
from celltypist import models
import scanpy as sc

# Download models (first time only)
models.download_models()

# Load your data (must be log1p normalized to 10,000 counts per cell)
adata = sc.read_h5ad('your_data.h5ad')

# Annotate with best immune model
predictions = celltypist.annotate(
    adata, 
    model='Immune_All_Low.pkl',  # High-resolution immune subtypes
    majority_voting=True          # Recommended: refines predictions using cell neighborhoods
)

# Get annotated AnnData
adata = predictions.to_adata()
# Results in: adata.obs['predicted_labels'], adata.obs['majority_voting'], adata.obs['conf_score']

# Save results
adata.write('annotated_data.h5ad')
```

## Pre-trained Immune Models

| Model | Description | Resolution |
|-------|-------------|------------|
| `Immune_All_Low.pkl` | All tissues, 98 immune subtypes | High (default) |
| `Immune_All_High.pkl` | All tissues, major immune types | Low |
| `Cells_Lung_Airway.pkl` | Lung/airway cells | High |
| `Cells_Intestinal_Tract.pkl` | Intestinal cells | High |
| `Human_Lung_Atlas.pkl` | Human lung atlas | High |

```python
# List all available models
models.models_description()

# Download specific model
models.download_models(model='Immune_All_Low.pkl')
```

## Key Parameters

### celltypist.annotate()

| Parameter | Default | Description |
|-----------|---------|-------------|
| `model` | 'Immune_All_Low.pkl' | Model name or path |
| `majority_voting` | False | **Recommended True**: refines predictions using local neighborhoods |
| `mode` | 'best match' | 'prob match' for multi-label classification |
| `p_thres` | 0.5 | Probability threshold (only for 'prob match' mode) |

### predictions.to_adata()

| Parameter | Default | Description |
|-----------|---------|-------------|
| `insert_labels` | True | Add predicted_labels to obs |
| `insert_conf` | True | Add confidence scores to obs |
| `insert_prob` | False | Add probability matrix to obs |

## Visualization

```python
# Compare predictions with existing annotations
celltypist.dotplot(predictions, 
                   use_as_reference='original_cell_type',  # Your existing annotation column
                   use_as_prediction='majority_voting')

# UMAP with predictions
sc.pl.umap(adata, color=['predicted_labels', 'majority_voting'])
```

## Data Requirements

**Input must be log1p normalized to 10,000 counts per cell:**

```python
# From raw counts
sc.pp.normalize_total(adata, target_sum=1e4)
sc.pp.log1p(adata)
```

**Verification:**
```python
# Should show values close to 10000
adata.X.expm1().sum(axis=1)
```

## Model Inspection

```python
# Load and inspect model
model = models.Model.load('Immune_All_Low.pkl')
print(model)                    # Model summary
print(model.cell_types)         # All cell types in model
print(model.features)           # Genes used by model

# Extract marker genes for a cell type
top_markers = model.extract_top_markers("CD8-positive, alpha-beta T cell", 10)
```

## Common Workflows

### 1. Basic Immune Annotation

Use `scripts/annotate_immune_cells.py`:

```bash
python scripts/annotate_immune_cells.py input.h5ad --output annotated.h5ad
```

### 2. Validate Against Manual Annotations

```python
# After annotation
celltypist.dotplot(predictions, 
                   use_as_reference='manual_annotation',
                   use_as_prediction='majority_voting')
```

### 3. High vs Low Resolution

```python
# High resolution (98 subtypes)
pred_low = celltypist.annotate(adata, model='Immune_All_Low.pkl', majority_voting=True)
adata.obs['celltype_fine'] = pred_low.predicted_labels.majority_voting

# Low resolution (major types)
pred_high = celltypist.annotate(adata, model='Immune_All_High.pkl', majority_voting=True)
adata.obs['celltype_coarse'] = pred_high.predicted_labels.majority_voting
```

## Bundled Resources

### scripts/annotate_immune_cells.py

Complete annotation script with CLI:

```bash
python scripts/annotate_immune_cells.py input.h5ad \
    --output annotated.h5ad \
    --model Immune_All_Low.pkl \
    --majority-voting
```

### references/model_selection.md

Guide for choosing the right model based on tissue and cell types.

### assets/immune_annotation_template.py

Complete analysis template. Copy and customize for your workflow:

```python
# Copy template to your project
# Customize INPUT_FILE, OUTPUT_FILE, MODEL_NAME
# Run the complete annotation workflow
```

## Tips

1. **Always use `majority_voting=True`** for more accurate predictions
2. **Check data normalization** before annotation (log1p to 10,000 counts)
3. **Start with `Immune_All_Low.pkl`** for general immune profiling
4. **Use dotplot** to validate predictions against existing annotations
5. **Include all genes** in input data for maximum overlap with model features

## Installation

```bash
pip install celltypist
# or
conda install -c bioconda -c conda-forge celltypist
```

## Citation

Dominguez Conde et al., Cross-tissue immune cell analysis reveals tissue-specific features in humans. Science 376, eabl5197 (2022).
