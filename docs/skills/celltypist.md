# celltypist

## Overview / 概览

`celltypist` focuses on automated cell type annotation for single-cell RNA-seq, with an emphasis on immune cell labeling through pretrained models.

`celltypist` 主要用于单细胞 RNA-seq 的自动细胞类型注释，特别适合免疫细胞场景下的快速初筛和标准化标注。

## Included / 包含内容

- `SKILL.md` describing annotation workflow and model choice
- `scripts/annotate_immune_cells.py` for practical execution
- `references/model_selection.md` for choosing pretrained models
- `assets/immune_annotation_template.py` as a reusable scaffold

## Best For / 适用场景

- Fast first-pass annotation of immune datasets
- Standardizing labels before downstream clustering or visualization
- Building a reproducible Python-based annotation routine

## Notes / 说明

The skill is strongest when paired with a clean `.h5ad` workflow and explicit marker-gene sanity checks after prediction.
