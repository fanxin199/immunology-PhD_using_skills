# ============================================================
# EnhancedVolcano - 完整示例脚本
# 
# 功能：展示 EnhancedVolcano 包的各种用法
# 输入：DESeq2/edgeR/limma 差异表达结果
# 输出：发表级火山图 (SVG/PNG/PDF)
# ============================================================

# ====================
# 1. 安装和加载包
# ====================
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

if (!require("EnhancedVolcano", quietly = TRUE))
    BiocManager::install("EnhancedVolcano")

library(EnhancedVolcano)
library(svglite)

# ====================
# 2. 发表级保存函数
# ====================
save_volcano <- function(plot_expr, filename, width = 10, height = 8, 
                          dpi = 300, output_dir = "figures") {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  
  # SVG
  svg(file.path(output_dir, paste0(filename, ".svg")), width = width, height = height)
  eval(plot_expr)
  dev.off()
  
  # PNG
  png(file.path(output_dir, paste0(filename, ".png")), 
      width = width, height = height, units = "in", res = dpi)
  eval(plot_expr)
  dev.off()
  
  # PDF
  pdf(file.path(output_dir, paste0(filename, ".pdf")), width = width, height = height)
  eval(plot_expr)
  dev.off()
  
  message(paste0("✅ 已保存: ", filename, " (.svg, .png, .pdf)"))
}

# ====================
# 3. 模拟示例数据
# ====================
set.seed(42)
n <- 5000

res <- data.frame(
  log2FoldChange = rnorm(n, 0, 1.5),
  pvalue = 10^(-runif(n, 0, 8)),
  padj = NA,
  row.names = paste0("Gene_", 1:n)
)
res$padj <- p.adjust(res$pvalue, method = "BH")

# 添加一些知名基因名用于演示
known_genes <- c("TP53", "BRCA1", "BRCA2", "EGFR", "MYC", "PTEN", 
                 "ATM", "KRAS", "PIK3CA", "CDH1", "RB1", "APC")
rownames(res)[1:length(known_genes)] <- known_genes
res$log2FoldChange[1:6] <- c(3.5, -2.8, 2.1, 4.2, -3.1, 1.8)
res$pvalue[1:6] <- c(1e-20, 1e-15, 1e-12, 1e-25, 1e-18, 1e-8)

# ====================
# 4. 示例1：基础火山图
# ====================
p1 <- EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    title = 'Basic Volcano Plot',
    pCutoff = 1e-5,
    FCcutoff = 1.5,
    pointSize = 2.5,
    labSize = 4.0)

print(p1)

# ====================
# 5. 示例2：带连接线
# ====================
p2 <- EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    title = 'Volcano with Connectors',
    pCutoff = 1e-6,
    FCcutoff = 1.5,
    pointSize = 3.0,
    labSize = 4.0,
    drawConnectors = TRUE,
    widthConnectors = 0.5,
    colConnectors = 'grey50')

print(p2)

# ====================
# 6. 示例3：仅标注特定基因
# ====================
genes_of_interest <- c("TP53", "BRCA1", "EGFR", "MYC")

p3 <- EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    title = 'Selected Gene Labels',
    selectLab = genes_of_interest,
    pCutoff = 1e-5,
    FCcutoff = 1.5,
    pointSize = 3.0,
    labSize = 5.0,
    drawConnectors = TRUE,
    boxedLabels = TRUE,
    colConnectors = 'black')

print(p3)

# ====================
# 7. 示例4：Nature 配色风格
# ====================
p4 <- EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    title = 'Nature Style',
    pCutoff = 1e-5,
    FCcutoff = 1.5,
    col = c('grey60', 'grey60', 'grey60', '#E64B35'),
    colAlpha = 0.8,
    pointSize = 3.0,
    labSize = 4.0,
    legendPosition = 'right',
    legendLabSize = 12)

print(p4)

# ====================
# 8. 示例5：自定义配色
# ====================
keyvals <- ifelse(
  res$log2FoldChange < -1.5 & res$pvalue < 1e-5, '#4DBBD5',
  ifelse(res$log2FoldChange > 1.5 & res$pvalue < 1e-5, '#E64B35', 'grey70'))
keyvals[is.na(keyvals)] <- 'grey70'
names(keyvals)[keyvals == '#E64B35'] <- 'Up-regulated'
names(keyvals)[keyvals == 'grey70'] <- 'Not significant'
names(keyvals)[keyvals == '#4DBBD5'] <- 'Down-regulated'

p5 <- EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    title = 'Custom Color Scheme',
    pCutoff = 1e-5,
    FCcutoff = 1.5,
    colCustom = keyvals,
    pointSize = 3.0,
    labSize = 4.0,
    drawConnectors = TRUE)

print(p5)

# ====================
# 9. 示例6：圈出特定基因集
# ====================
pathway_genes <- c("TP53", "BRCA1", "BRCA2", "ATM")

p6 <- EnhancedVolcano(res,
    lab = rownames(res),
    x = 'log2FoldChange',
    y = 'pvalue',
    title = 'DNA Repair Pathway Highlighted',
    selectLab = pathway_genes,
    pCutoff = 1e-5,
    FCcutoff = 1.5,
    pointSize = 3.0,
    labSize = 5.0,
    encircle = pathway_genes,
    encircleCol = '#00468B',
    encircleSize = 2,
    encircleFill = '#00468B',
    encircleAlpha = 0.15,
    drawConnectors = TRUE)

print(p6)

# ====================
# 10. 保存所有图形
# ====================
message("\n正在保存所有图形...")

if (!dir.exists("figures")) dir.create("figures")

pdf("figures/volcano_basic.pdf", width = 10, height = 8)
print(p1)
dev.off()

pdf("figures/volcano_connectors.pdf", width = 10, height = 8)
print(p2)
dev.off()

pdf("figures/volcano_selected.pdf", width = 10, height = 8)
print(p3)
dev.off()

pdf("figures/volcano_nature.pdf", width = 10, height = 8)
print(p4)
dev.off()

pdf("figures/volcano_custom_colors.pdf", width = 10, height = 8)
print(p5)
dev.off()

pdf("figures/volcano_encircle.pdf", width = 10, height = 8)
print(p6)
dev.off()

message("
╔════════════════════════════════════════════════════════════╗
║  EnhancedVolcano 示例完成！                                ║
║                                                            ║
║  生成的图形：                                              ║
║  - volcano_basic.pdf      基础火山图                       ║
║  - volcano_connectors.pdf 带连接线                         ║
║  - volcano_selected.pdf   标注特定基因                     ║
║  - volcano_nature.pdf     Nature风格配色                   ║
║  - volcano_custom_colors  自定义配色                       ║
║  - volcano_encircle.pdf   圈出基因集                       ║
╚════════════════════════════════════════════════════════════╝
")
