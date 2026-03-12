# ============================================================
# BioViz Pro - PCA主成分分析图 模板
# 用途：展示样本间的整体差异和聚类关系
# ============================================================

library(ggplot2)
library(ggsci)
library(ggpubr)
library(ggrepel)
library(svglite)
library(dplyr)

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
  message(paste0("✅ 图形已保存: ", output_dir, "/", filename))
}

# 模拟数据
set.seed(42)
n_genes <- 1000; n_samples <- 12
sample_names <- c(paste0("Control_", 1:4), paste0("Treatment_A_", 1:4), paste0("Treatment_B_", 1:4))
expr_matrix <- matrix(rnorm(n_genes * n_samples, 10, 3), n_genes, n_samples)
colnames(expr_matrix) <- sample_names
expr_matrix[, 5:8] <- expr_matrix[, 5:8] + 2
expr_matrix[, 9:12] <- expr_matrix[, 9:12] - 1

sample_info <- data.frame(
  Sample = sample_names,
  Group = c(rep("Control", 4), rep("Treatment_A", 4), rep("Treatment_B", 4)),
  row.names = sample_names
)

# 执行PCA
pca_result <- prcomp(t(expr_matrix), center = TRUE, scale. = TRUE)
pca_data <- as.data.frame(pca_result$x)
pca_data$Sample <- rownames(pca_data)
pca_data <- merge(pca_data, sample_info, by = "Sample")
var_explained <- round(100 * summary(pca_result)$importance[2, ], 2)

# 带椭圆的PCA图
pca_plot <- ggplot(pca_data, aes(x = PC1, y = PC2, color = Group, fill = Group)) +
  stat_ellipse(geom = "polygon", alpha = 0.15, level = 0.95, show.legend = FALSE) +
  geom_point(size = 4, alpha = 0.9) +
  scale_color_npg() + scale_fill_npg() +
  labs(title = "PCA with 95% Confidence Ellipses",
       x = paste0("PC1 (", var_explained[1], "%)"),
       y = paste0("PC2 (", var_explained[2], "%)"), color = "Group") +
  theme_pubr(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"), aspect.ratio = 1)

save_publication_figure(pca_plot, "pca_plot_NPG", width = 8, height = 7)
