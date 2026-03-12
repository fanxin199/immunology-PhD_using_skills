# spatial-transcriptomics

## Overview / 概览

`spatial-transcriptomics` is the umbrella skill for end-to-end spatial omics workflows, centered on Python tooling such as Scanpy, Squidpy, and SpatialData.

`spatial-transcriptomics` 是整个仓库里最完整的总入口技能之一，覆盖空间转录组从数据导入、预处理、邻域图、空间统计、组织区域识别到可视化、通信分析和去卷积的全过程。

## Included / 包含内容

- Top-level `SKILL.md` as the workflow hub
- Eleven nested module folders, each with its own `SKILL.md`
- Script support inside selected submodules for practical execution
- Existing nested documentation such as `usage-guide.md` files

## Module Map / 子模块清单

| Module | Purpose / 作用 |
| --- | --- |
| `spatial-data-io` | Load Visium, Xenium, MERFISH, Slide-seq, and related inputs |
| `spatial-preprocessing` | QC, filtering, normalization, and feature selection |
| `spatial-neighbors` | Build spatial graphs and neighborhood structures |
| `spatial-statistics` | Moran's I, co-occurrence, enrichment, and related spatial stats |
| `spatial-domains` | Tissue regions and spatial domain discovery |
| `spatial-visualization` | Feature maps, overlays, and report-ready plotting |
| `image-analysis` | Tissue-image processing and derived features |
| `spatial-communication` | Ligand-receptor and cell-cell interaction workflows |
| `spatial-deconvolution` | Reference-based deconvolution approaches |
| `spatial-multiomics` | High-resolution or multiomic spatial platforms |
| `spatial-proteomics` | CODEX, IMC, MIBI, and related protein-space workflows |

## Best For / 适用场景

- Building a full spatial analysis path inside a single skill tree
- Selecting the right sub-workflow without leaving the repository
- Supporting both classic Visium analyses and broader spatial omics expansion

## Notes / 说明

This folder remains nested on purpose. It acts as a workflow hub rather than a single narrow skill.
