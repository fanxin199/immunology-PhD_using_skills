---
name: squidpy-spatial-viz
description: 空间转录组数据可视化技能，基于 Squidpy (Nature Methods 2022)。当用户需要：(1) 可视化空间转录组数据（Visium, Slide-seq, Xenium等）(2) 绑制空间散点图、组织图像叠加、空间特征图 (3) 展示空间统计结果（邻域富集、共现分析、Moran's I）(4) 生成发表级空间转录组图形时使用此技能。本技能使用 Python + Squidpy + Scanpy 生态。
---

# Squidpy Spatial Viz - 空间转录组可视化

基于 [Squidpy](https://squidpy.readthedocs.io/) 的空间转录组数据可视化技能包。

## 安装

```bash
pip install squidpy scanpy matplotlib seaborn
```

## 快速开始

```python
import squidpy as sq
import scanpy as sc

# 加载示例数据（Visium）
adata = sq.datasets.visium_hne_adata()

# 空间散点图
sq.pl.spatial_scatter(adata, color="cluster")

# 保存发表级图形
import matplotlib.pyplot as plt
plt.savefig("spatial_plot.svg", dpi=300, bbox_inches='tight')
plt.savefig("spatial_plot.png", dpi=300, bbox_inches='tight')
```

## 核心可视化函数

### 空间图 (`sq.pl`)

| 函数 | 用途 |
|------|------|
| `sq.pl.spatial_scatter()` | 空间散点图，展示细胞/spot分布 |
| `sq.pl.spatial_segment()` | 空间分割可视化 |
| `sq.pl.nhood_enrichment()` | 邻域富集分析热图 |
| `sq.pl.co_occurrence()` | 共现分析图 |
| `sq.pl.centrality_scores()` | 中心性评分可视化 |
| `sq.pl.ligrec()` | 配体-受体交互可视化 |
| `sq.pl.ripley()` | Ripley's 统计可视化 |

### 图像分析 (`sq.im`)

| 函数 | 用途 |
|------|------|
| `sq.pl.extract()` | 图像特征提取可视化 |
| 使用 napari | 交互式探索组织图像 |

## 常用模板

详见 `scripts/` 目录下的模板：
- `spatial_scatter.py` - 空间散点图模板
- `spatial_features.py` - 空间特征图模板
- `nhood_analysis.py` - 邻域分析可视化
- `utils.py` - 通用保存函数

## 发表级图形设置

```python
import matplotlib.pyplot as plt

# 设置发表级参数
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.family'] = 'Arial'
plt.rcParams['font.size'] = 12

# 保存函数
def save_figure(fig, filename, formats=['svg', 'png', 'pdf']):
    for fmt in formats:
        fig.savefig(f"{filename}.{fmt}", dpi=300, bbox_inches='tight')
```

## 支持的数据平台

- 10x Visium
- 10x Xenium  
- Slide-seq
- MERFISH
- seqFISH
- STARmap
- 其他空间转录组平台

## 参考资源

- [Squidpy 官方文档](https://squidpy.readthedocs.io/)
- [Squidpy 教程](https://squidpy.readthedocs.io/en/stable/tutorials.html)
- [原始论文 (Nature Methods 2022)](https://doi.org/10.1038/s41592-021-01358-2)
