# ggsci 配色方案详细参考

## 期刊配色 HEX 值

### Nature (NPG)
```
#E64B35 #4DBBD5 #00A087 #3C5488 #F39B7F #8491B4 #91D1C2 #DC0000 #7E6148 #B09C85
```

### Science (AAAS)
```
#3B4992 #EE0000 #008B45 #631879 #008280 #BB0021 #5F559B #A20056 #808180 #1B1919
```

### NEJM
```
#BC3C29 #0072B5 #E18727 #20854E #7876B1 #6F99AD #FFDC91 #EE4C97
```

### Lancet
```
#00468B #ED0000 #42B540 #0099B4 #925E9F #FDAF91 #AD002A #ADB6B6 #1B1919
```

### JAMA
```
#374E55 #DF8F44 #00A1D5 #B24745 #79AF97 #6A6599 #80796B
```

### JCO
```
#0073C2 #EFC000 #868686 #CD534C #7AA6DC #003C67 #8F7700 #3B3B3B #A73030 #4A6990
```

### BMJ
```
#336699 #8C8C8C #E2A854 #2C5C34 #7E4E90 #CF4520 #C7B800 #01665E #A65628
```

## 生物信息学配色

### UCSC Genome Browser
用于染色体可视化，26色循环

### IGV
基因组浏览器配色，51色

### LocusZoom
GWAS Manhattan图配色，7色

### COSMIC
突变签名配色，12色 hallmarks + signatures

## 差异表达常用三色

| 期刊 | 上调 | 下调 | 无显著 |
|------|------|------|--------|
| NPG | #E64B35 | #4DBBD5 | #999999 |
| Lancet | #AD002A | #00468BFF | #999999 |
| NEJM | #BC3C29 | #0072B5 | #999999 |
| JAMA | #DF8F44 | #374E55 | #999999 |
| JCO | #CD534C | #0073C2 | #999999 |

## 热图渐变色

### 蓝-白-红（表达量）
```r
colorRampPalette(c("#2166AC", "#F7F7F7", "#B2182B"))(100)
```

### 紫-白-绿
```r
colorRampPalette(c("#7B3294", "#F7F7F7", "#008837"))(100)
```

### GSEA 渐变
```r
scale_fill_gsea()  # 蓝-白-红连续渐变
```
