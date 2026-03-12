---
name: bioviz-pro
description: 生物信息学发表级数据可视化技能，基于 ggsci 期刊配色方案。当用户需要：(1) 绑制生物信息学图表（火山图、MA图、热图、PCA图、生存曲线、箱线图、富集分析图、Manhattan图）(2) 使用顶级期刊配色（Nature/Science/Lancet/NEJM/JAMA/BMJ/JCO等）(3) 生成发表级矢量图（SVG/PDF，300 DPI PNG）(4) 快速应用 ggsci 配色方案到 ggplot2 图形时使用此技能。
---

# BioViz Pro - 生物信息学发表级可视化

基于 ggsci 配色方案的生物信息学可视化工具包，生成 Nature/Science/Lancet 等顶级期刊发表级图形。

## 安装依赖

```r
install.packages(c("ggplot2", "ggsci", "ggpubr", "ggrepel", "svglite",
                   "pheatmap", "survival", "survminer", "corrplot"))
```

## 快速开始

```r
library(ggplot2)
library(ggsci)
library(ggpubr)

# 使用期刊配色
p <- ggplot(data, aes(x, y, color = group)) +
  geom_point() +
  scale_color_npg() +  # Nature 配色
  theme_pubr()

# 保存发表级图形
source("scripts/utils.R")
save_publication_figure(p, "my_figure")
```

## 期刊配色速查

| 期刊 | 颜色函数 | 填充函数 |
|------|----------|----------|
| Nature | `scale_color_npg()` | `scale_fill_npg()` |
| Science | `scale_color_aaas()` | `scale_fill_aaas()` |
| NEJM | `scale_color_nejm()` | `scale_fill_nejm()` |
| Lancet | `scale_color_lancet()` | `scale_fill_lancet()` |
| JAMA | `scale_color_jama()` | `scale_fill_jama()` |
| JCO | `scale_color_jco()` | `scale_fill_jco()` |
| BMJ | `scale_color_bmj()` | `scale_fill_bmj()` |

生物信息学配色：`scale_color_ucscgb()`, `scale_color_igv()`, `scale_color_locuszoom()`, `scale_color_cosmic()`

## 可用图表模板

使用方法：`source("scripts/<模板名>.R")`

| 模板 | 用途 |
|------|------|
| `volcano_plot.R` | 差异表达火山图 |
| `ma_plot.R` | MA图（均值-差异图） |
| `heatmap.R` | 表达量热图（pheatmap/ComplexHeatmap） |
| `pca_plot.R` | PCA主成分分析图 |
| `survival_curve.R` | Kaplan-Meier生存曲线 |
| `boxplot_violin.R` | 箱线图/小提琴图 |
| `correlation_plot.R` | 相关性分析图 |
| `enrichment_plot.R` | GO/KEGG富集分析图 |
| `manhattan_plot.R` | GWAS Manhattan图 |

## 核心函数

### 保存发表级图形

```r
save_publication_figure(plot_obj, filename, width = 7, height = 6, dpi = 300)
# 自动生成 SVG + PNG + PDF 三种格式
```

### 获取期刊配色

```r
get_journal_colors("npg", n = 10)   # 返回 Nature 配色向量
get_deg_colors("lancet")            # 返回上调/下调/NS三色
```

## 期刊尺寸参考

| 期刊 | 单栏 | 双栏 |
|------|------|------|
| Nature | 3.5×3 | 7.2×5 |
| Science | 3.5×3 | 7×5 |
| Cell | 3.35×3 | 6.85×5 |

## 参考资源

- 配色详情：[references/color_palettes.md](references/color_palettes.md)
- [ggsci 官方文档](https://nanx.me/ggsci/)
