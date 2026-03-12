# EnhancedVolcano 完整参数参考

## 基础参数

| 参数 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `toptable` | data.frame | 差异表达结果 | 必填 |
| `lab` | character | 基因标签向量 | 必填 |
| `x` | character | x轴列名 | 'log2FoldChange' |
| `y` | character | y轴列名 | 'pvalue' |
| `xlim` | numeric(2) | x轴范围 | 自动 |
| `ylim` | numeric(2) | y轴范围 | 自动 |

## 阈值参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `pCutoff` | P值显著性阈值 | 1e-05 |
| `FCcutoff` | log2FC阈值 | 1.0 |
| `pCutoffCol` | 用于截断的P值列名 | y列 |

## 标题和标签

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `title` | 图形标题 | '' |
| `subtitle` | 副标题 | '' |
| `caption` | 标注 | '' |
| `xlab` | x轴标签 | log2FC表达式 |
| `ylab` | y轴标签 | -log10(p)表达式 |

## 点样式

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `pointSize` | 点大小 | 2.0 |
| `shape` | 点形状 | 19 |
| `shapeCustom` | 自定义形状向量 | NULL |
| `colAlpha` | 透明度 | 0.5 |

## 颜色设置

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `col` | 四色向量(NS, log2FC, P, Both) | c('grey30','forestgreen','royalblue','red2') |
| `colCustom` | 自定义颜色key-value | NULL |
| `colGradient` | 渐变色向量 | NULL |

## 标签设置

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `labSize` | 标签字号 | 3.0 |
| `labCol` | 标签颜色 | 'black' |
| `selectLab` | 指定显示的基因 | NULL |
| `boxedLabels` | 标签加框 | FALSE |
| `parseLabels` | 解析表达式标签 | FALSE |

## 连接线

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `drawConnectors` | 显示连接线 | FALSE |
| `widthConnectors` | 连接线宽度 | 0.5 |
| `colConnectors` | 连接线颜色 | 'grey10' |
| `typeConnectors` | 线型 | 'closed' |
| `lengthConnectors` | 箭头长度 | unit(0.01, 'npc') |
| `endsConnectors` | 箭头位置 | 'first' |

## 圈出基因

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `encircle` | 要圈出的基因 | '' |
| `encircleCol` | 圈线颜色 | 'black' |
| `encircleSize` | 圈线粗细 | 2.5 |
| `encircleFill` | 圈填充色 | 'pink' |
| `encircleAlpha` | 圈透明度 | 1/4 |

## 阈值线

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `cutoffLineType` | 线型 | 'longdash' |
| `cutoffLineCol` | 线颜色 | 'black' |
| `cutoffLineWidth` | 线宽 | 0.4 |
| `hline` | 水平线位置 | NULL |
| `vline` | 垂直线位置 | NULL |
| `hlineCol`, `vlineCol` | 线颜色 | 'black' |

## 图例

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `legendPosition` | 位置: 'top', 'bottom', 'left', 'right', 'none' | 'top' |
| `legendLabSize` | 图例字号 | 14 |
| `legendIconSize` | 图标大小 | 5.0 |
| `legendLabels` | 自定义图例标签 | 自动生成 |

## 网格和边框

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `gridlines.major` | 主网格线 | TRUE |
| `gridlines.minor` | 次网格线 | TRUE |
| `border` | 边框: 'full', 'partial' | 'partial' |
| `borderWidth` | 边框宽度 | 0.8 |
| `borderColour` | 边框颜色 | 'black' |
