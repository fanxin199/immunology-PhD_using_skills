# ============================================================
# BioViz Pro - 箱线图/小提琴图模板
# 用途：展示基因表达量分布，组间比较
# ============================================================

library(ggplot2)
library(ggsci)
library(ggpubr)
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
expr_data <- data.frame(
  Gene = rep(c("TP53", "BRCA1", "EGFR", "MYC"), each = 60),
  Expression = c(rnorm(30, 8, 1.5), rnorm(30, 12, 2),      # TP53
                 rnorm(30, 6, 1), rnorm(30, 5, 1.2),        # BRCA1
                 rnorm(30, 10, 1.8), rnorm(30, 15, 2.5),    # EGFR
                 rnorm(30, 7, 1.2), rnorm(30, 11, 1.8)),    # MYC
  Group = rep(rep(c("Normal", "Tumor"), each = 30), 4)
)
expr_data$Group <- factor(expr_data$Group, levels = c("Normal", "Tumor"))

# NPG 配色
npg_colors <- pal_npg("nrc")(10)

# ============ 1. 分组箱线图 ============
boxplot_grouped <- ggplot(expr_data, aes(x = Gene, y = Expression, fill = Group)) +
  geom_boxplot(alpha = 0.8, outlier.shape = 21, width = 0.7) +
  scale_fill_npg() +
  stat_compare_means(aes(group = Group), method = "t.test", 
                     label = "p.signif", label.y.npc = 0.95) +
  labs(title = "Gene Expression Comparison",
       x = NULL, y = "Expression Level (log2)", fill = "Group") +
  theme_pubr(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        legend.position = "right")

save_publication_figure(boxplot_grouped, "boxplot_grouped", width = 8, height = 6)

# ============ 2. 小提琴图 + 箱线图组合 ============
violin_box <- ggplot(expr_data, aes(x = Gene, y = Expression, fill = Group)) +
  geom_violin(alpha = 0.6, position = position_dodge(0.9), trim = FALSE) +
  geom_boxplot(width = 0.15, position = position_dodge(0.9), 
               alpha = 0.9, outlier.size = 0.5) +
  scale_fill_npg() +
  labs(title = "Gene Expression Distribution",
       x = NULL, y = "Expression Level (log2)", fill = "Group") +
  theme_pubr(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

save_publication_figure(violin_box, "violin_boxplot", width = 8, height = 6)

# ============ 3. 单基因详细箱线图 ============
single_gene <- expr_data %>% filter(Gene == "EGFR")
boxplot_single <- ggplot(single_gene, aes(x = Group, y = Expression, fill = Group)) +
  geom_boxplot(alpha = 0.8, width = 0.5) +
  geom_jitter(width = 0.15, alpha = 0.5, size = 2) +
  scale_fill_manual(values = c(npg_colors[4], npg_colors[1])) +
  stat_compare_means(method = "t.test", label.x = 1.5, label.y = max(single_gene$Expression) + 1) +
  labs(title = "EGFR Expression", x = NULL, y = "Expression (log2)") +
  theme_pubr(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"), legend.position = "none")

save_publication_figure(boxplot_single, "boxplot_EGFR", width = 5, height = 6)

message("
╔════════════════════════════════════════════════════════════╗
║  箱线图/小提琴图绑制完成！                                 ║
╚════════════════════════════════════════════════════════════╝
")
