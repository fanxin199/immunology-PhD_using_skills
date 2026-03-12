# CellTypist Model Selection Guide

## Quick Selection

| Your Data | Recommended Model |
|-----------|-------------------|
| General immune profiling | `Immune_All_Low.pkl` (default) |
| Major cell type overview | `Immune_All_High.pkl` |
| Lung/airway samples | `Cells_Lung_Airway.pkl` |
| Intestinal samples | `Cells_Intestinal_Tract.pkl` |
| Human lung atlas reference | `Human_Lung_Atlas.pkl` |

## Model Hierarchy

### Low vs High Hierarchy

- **Low hierarchy** (`*_Low.pkl`): High resolution, many fine-grained subtypes (e.g., 98 immune subtypes)
- **High hierarchy** (`*_High.pkl`): Low resolution, major cell categories only

**Recommendation**: Start with `Low` for detailed immune profiling, use `High` for overview or when data quality is limited.

## All Available Models

List models programmatically:

```python
from celltypist import models
models.models_description()
```

## Model-Specific Cell Types

```python
from celltypist import models

# Load and inspect any model
model = models.Model.load('Immune_All_Low.pkl')

# See all cell types
print(model.cell_types)

# Check if a specific cell type is in the model
'CD8-positive, alpha-beta T cell' in model.cell_types
```

## Multi-Model Strategy

For comprehensive annotation, run both resolution levels:

```python
import celltypist

# Fine-grained subtypes
pred_fine = celltypist.annotate(adata, model='Immune_All_Low.pkl', majority_voting=True)
adata.obs['celltype_fine'] = pred_fine.predicted_labels.majority_voting

# Major categories
pred_coarse = celltypist.annotate(adata, model='Immune_All_High.pkl', majority_voting=True)
adata.obs['celltype_coarse'] = pred_coarse.predicted_labels.majority_voting
```

## Cross-Tissue Considerations

The `Immune_All_*` models are trained on cells from multiple tissues:
- Blood (PBMC)
- Bone marrow
- Spleen
- Lymph nodes
- Lung
- Gut
- Skin
- etc.

This makes them robust for general immune profiling but may miss tissue-resident specializations. For tissue-specific applications, prefer tissue-specific models if available.
