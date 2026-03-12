# ============================================================
# BioViz Pro - 相关性分析图模板
# 用途：展示基因表达相关性、样本相关性
# ============================================================

library(ggplot2)
library(ggsci)
library(ggpubr)
library(corrplot)
library(pheatmap)
library(svglite)

# 发表级保存函数
save_publication_figure <- function(plot_obj, filename, width = 7, height = 6, 
                                     dpi = 300, output_dir = "figures") {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  ggsave(file.path(output_dir, paste0(filename, ".svg")),
         plot_obj, width = width, height = height, device = svglite::svglite)
  ggsave(file.path(output_dir, paste0(filename, ".png")),
         plot_obj, width = width, height = height, dpi = dpi, bg = "white")
  ggsave(file.path(output_dir, paste0(filename, ".pdf")),
         plot_obj, width = width, height = height, device = cairo_pdf)
}

# 模拟数据
set.seed(42)
n <- 50
gene_data <- data.frame(
  TP53 = rnorm(n, 10, 2),
  BRCA1 = rnorm(n, 8, 1.5),
  EGFR = rnorm(n, 12, 3),
  MYC = rnorm(n, 9, 2),
  PTEN = rnorm(n, 7, 1.8)
)
# 添加相关性
gene_data$BRCA1 <- gene_data$BRCA1 + 0.5 * gene_data$TP53
gene_data$MYC <- gene_data$MYC - 0.4 * gene_data$PTEN

# ============ 1. 散点图 + 回归线 ============
scatter_plot <- ggplot(gene_data, aes(x = TP53, y = BRCA1)) +
  geom_point(color = pal_npg()(1), size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", color = pal_npg()(2), fill = pal_npg()(2), alpha = 0.2) +
  stat_cor(method = "pearson", label.x = min(gene_data$TP53), 
           label.y = max(gene_data$BRCA1), size = 4) +
  labs(title = "TP53 vs BRCA1 Expression Correlation",
       x = "TP53 Expression (log2)", y = "BRCA1 Expression (log2)") +
  theme_pubr(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

save_publication_figure(scatter_plot, "correlation_scatter", width = 6, height = 6)

# ============ 2. 相关性矩阵热图 ============
cor_matrix <- cor(gene_data, method = "pearson")

# 使用 corrplot
if (!dir.exists("figures")) dir.create("figures")
png("figures/correlation_matrix.png", width = 7, height = 7, units = "in", res = 300)
corrplot(cor_matrix, method = "color", type = "upper",
         col = colorRampPalette(c("#2166AC", "white", "#B2182B"))(100),
         addCoef.col = "black", number.cex = 0.8,
         tl.col = "black", tl.srt = 45,
         diag = FALSE, title = "Gene Expression Correlation",
         mar = c(0, 0, 2, 0))
dev.off()

# PDF 版本
cairo_pdf("figures/correlation_matrix.pdf", width = 7, height = 7)
corrplot(cor_matrix, method = "color", type = "upper",
         col = colorRampPalette(c("#2166AC", "white", "#B2182B"))(100),
         addCoef.col = "black", number.cex = 0.8,
         tl.col = "black", diag = FALSE)
dev.off()

# SVG 版本
svglite::svglite("figures/correlation_matrix.svg", width = 7, height = 7)
corrplot(cor_matrix, method = "color", type = "upper",
         col = colorRampPalette(c("#2166AC", "white", "#B2182B"))(100),
         addCoef.col = "black", number.cex = 0.8,
         tl.col = "black", diag = FALSE)
dev.off()

# ============ 3. 相关性热图（pheatmap） ============
png("figures/correlation_heatmap.png", width = 7, height = 6, units = "in", res = 300)
pheatmap(cor_matrix, 
         color = colorRampPalette(c("#2166AC", "white", "#B2182B"))(100),
         display_numbers = TRUE, number_format = "%.2f",
         main = "Gene Correlation Matrix",
         fontsize = 12, fontsize_number = 10)
dev.off()

message("
╔════════════════════════════════════════════════════════════╗
║  相关性分析图绑制完成！                                    ║
║  - correlation_scatter: 散点图 + 回归线                    ║
║  - correlation_matrix: 相关性矩阵                          ║
╚════════════════════════════════════════════════════════════╝
")
