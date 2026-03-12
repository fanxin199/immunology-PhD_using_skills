---
name: enhanced-volcano
description: 使用 EnhancedVolcano 包绑制发表级火山图。当用户需要绑制差异表达分析的火山图，特别是需要：(1) 智能标签避让，自动优化基因名显示 (2) 标注特定基因集或通路 (3) 使用连接线连接标签和数据点 (4) 同时展示多维信息（颜色、形状、大小、透明度） (5) 圈出/高亮特定基因 (6) 生成发表级矢量图（SVG/PDF）时使用此技能。本技能基于 Bioconductor EnhancedVolcano 包。
---

# EnhancedVolcano - 发表级火山图技能

基于 [EnhancedVolcano](https://github.com/kevinblighe/EnhancedVolcano) Bioconductor 包，用于生成高度定制化的发表级火山图。

## 安装

```r
# Bioconductor 安装
if (!require("BiocManager")) install.packages("BiocManager")
BiocManager::install("EnhancedVolcano")

# 辅助包
install.packages(c("svglite", "ggrepel"))
```

## 快速开始

```r
library(EnhancedVolcano)

# 基础火山图（res 为 DESeq2/edgeR/limma 结果）
EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue')
```

## 核心参数速查

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `lab` | 基因标签向量 | rownames(res) |
| `x` | x轴列名 | 'log2FoldChange' |
| `y` | y轴列名 | 'pvalue' |
| `pCutoff` | P值阈值 | 1e-6 |
| `FCcutoff` | log2FC阈值 | 1.0 |
| `pointSize` | 点大小 | 2.0 |
| `labSize` | 标签字号 | 5.0 |
| `col` | 四色向量 | c('grey30','forestgreen','royalblue','red2') |
| `colAlpha` | 透明度 | 0.5 |
| `drawConnectors` | 显示连接线 | FALSE |
| `selectLab` | 指定标注基因 | NULL |
| `legendPosition` | 图例位置 | 'top' |

## 常用模板

### 模板1：基础发表级火山图

```r
EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    title = 'Treatment vs Control',
    pCutoff = 1e-5,
    FCcutoff = 1.5,
    pointSize = 3.0,
    labSize = 4.0,
    legendPosition = 'right')
```

### 模板2：带连接线的火山图

```r
EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    pCutoff = 1e-6,
    FCcutoff = 1.5,
    pointSize = 3.0,
    labSize = 4.0,
    drawConnectors = TRUE,
    widthConnectors = 0.5,
    colConnectors = 'grey50',
    maxoverlapsConnectors = 80)
```

### 模板3：仅标注特定基因

```r
# 指定要标注的基因列表
genes_to_label <- c("TP53", "BRCA1", "EGFR", "MYC", "PTEN")

EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    selectLab = genes_to_label,
    pCutoff = 1e-6,
    FCcutoff = 1.5,
    drawConnectors = TRUE,
    boxedLabels = TRUE)
```

### 模板4：自定义配色（Nature风格）

```r
# NPG 配色
EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    pCutoff = 1e-6,
    FCcutoff = 1.5,
    col = c('grey60', 'grey60', 'grey60', '#E64B35'),  # 仅显著基因为红色
    colAlpha = 0.8,
    pointSize = 3.0,
    labSize = 4.0)
```

### 模板5：自定义 key-value 配色

```r
# 根据表达变化自定义颜色
keyvals <- ifelse(
  res$log2FoldChange < -1.5, 'royalblue',
  ifelse(res$log2FoldChange > 1.5, 'red3', 'grey50'))
keyvals[is.na(keyvals)] <- 'grey50'
names(keyvals)[keyvals == 'red3'] <- 'Up'
names(keyvals)[keyvals == 'grey50'] <- 'NS'
names(keyvals)[keyvals == 'royalblue'] <- 'Down'

EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    colCustom = keyvals,
    pCutoff = 1e-6,
    FCcutoff = 1.5)
```

### 模板6：圈出特定基因集

```r
# 高亮特定通路的基因
pathway_genes <- c("BRCA1", "BRCA2", "ATM", "CHEK2")

EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    selectLab = pathway_genes,
    pCutoff = 1e-6,
    FCcutoff = 1,
    encircle = pathway_genes,
    encircleCol = 'black',
    encircleSize = 2.5,
    encircleFill = 'pink',
    encircleAlpha = 0.25)
```

## 保存发表级图形

```r
# 保存为 SVG（期刊投稿首选）
svg("volcano_plot.svg", width = 10, height = 8)
EnhancedVolcano(res, lab = rownames(res), x = 'log2FoldChange', y = 'pvalue')
dev.off()

# 保存为高清 PNG
png("volcano_plot.png", width = 10, height = 8, units = "in", res = 300)
EnhancedVolcano(res, lab = rownames(res), x = 'log2FoldChange', y = 'pvalue')
dev.off()

# 保存为 PDF
pdf("volcano_plot.pdf", width = 10, height = 8)
EnhancedVolcano(res, lab = rownames(res), x = 'log2FoldChange', y = 'pvalue')
dev.off()
```

## 期刊配色参考

| 期刊 | 显著色 | 非显著色 | 配色代码 |
|------|--------|----------|----------|
| Nature | #E64B35 | #999999 | `col=c('grey60','grey60','grey60','#E64B35')` |
| Lancet | #AD002A | #999999 | `col=c('grey60','grey60','grey60','#AD002A')` |
| NEJM | #BC3C29 | #0072B5 | `col=c('grey60','#0072B5','grey60','#BC3C29')` |
| JAMA | #DF8F44 | #374E55 | `col=c('grey60','#374E55','grey60','#DF8F44')` |

## 参考资源

- [官方文档](https://bioconductor.org/packages/EnhancedVolcano/)
- [GitHub](https://github.com/kevinblighe/EnhancedVolcano)
- [Vignette](https://bioconductor.org/packages/release/bioc/vignettes/EnhancedVolcano/inst/doc/EnhancedVolcano.html)
