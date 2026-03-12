# ============================================================
# BioViz Pro - GWAS Manhattan 图模板
# 用途：展示全基因组关联分析结果
# ============================================================

library(ggplot2)
library(ggsci)
library(ggpubr)
library(svglite)
library(dplyr)

# 发表级保存函数
save_publication_figure <- function(plot_obj, filename, width = 12, height = 5, 
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

# 模拟 GWAS 数据
set.seed(42)
n_snps <- 10000
chr_sizes <- c(250, 243, 200, 191, 182, 171, 159, 146, 140, 135,
               135, 134, 115, 107, 102, 90, 83, 80, 59, 64, 47, 51)

gwas_data <- data.frame(
  CHR = rep(1:22, times = round(n_snps * chr_sizes / sum(chr_sizes)))
)
gwas_data <- gwas_data[1:n_snps, , drop = FALSE]
gwas_data$BP <- unlist(lapply(1:22, function(chr) {
  n <- sum(gwas_data$CHR == chr)
  sort(sample(1:(chr_sizes[chr] * 1e6), n))
}))
gwas_data$P <- runif(n_snps)^5  # 大多数不显著
# 添加一些显著位点
sig_idx <- sample(1:n_snps, 50)
gwas_data$P[sig_idx] <- 10^(-runif(50, 5, 12))
gwas_data$SNP <- paste0("rs", 1:n_snps)

# 计算绘图位置
gwas_data <- gwas_data %>%
  group_by(CHR) %>%
  mutate(BP_cum = BP + (CHR - 1) * 3e8) %>%
  ungroup()

# 染色体中心位置（用于x轴标签）
axis_df <- gwas_data %>%
  group_by(CHR) %>%
  summarize(center = mean(BP_cum))

# 显著性阈值
sig_threshold <- 5e-8
suggestive_threshold <- 1e-5

# 配色
chr_colors <- rep(c(pal_npg()(1), pal_npg()(4)), 11)

# Manhattan 图
manhattan_plot <- ggplot(gwas_data, aes(x = BP_cum, y = -log10(P), color = factor(CHR))) +
  geom_point(alpha = 0.7, size = 1.2) +
  scale_color_manual(values = chr_colors, guide = "none") +
  scale_x_continuous(breaks = axis_df$center, labels = axis_df$CHR) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  geom_hline(yintercept = -log10(sig_threshold), color = "red", 
             linetype = "dashed", linewidth = 0.6) +
  geom_hline(yintercept = -log10(suggestive_threshold), color = "blue", 
             linetype = "dashed", linewidth = 0.5) +
  labs(title = "Manhattan Plot",
       x = "Chromosome", y = expression(-log[10](P-value))) +
  theme_pubr(base_size = 11) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
        axis.text.x = element_text(size = 9),
        panel.grid.major.x = element_blank())

save_publication_figure(manhattan_plot, "manhattan_plot", width = 14, height = 5)

# ============ QQ Plot ============
observed <- sort(-log10(gwas_data$P))
expected <- -log10(ppoints(length(observed)))
qq_data <- data.frame(Expected = expected, Observed = observed)

qq_plot <- ggplot(qq_data, aes(x = Expected, y = Observed)) +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  geom_point(color = pal_npg()(1), alpha = 0.6, size = 1.5) +
  labs(title = "QQ Plot",
       x = expression(Expected~~-log[10](P)),
       y = expression(Observed~~-log[10](P))) +
  theme_pubr(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        aspect.ratio = 1)

save_publication_figure(qq_plot, "qq_plot", width = 6, height = 6)

message("
╔════════════════════════════════════════════════════════════╗
║  GWAS 图绑制完成！                                         ║
║  - manhattan_plot: Manhattan图                             ║
║  - qq_plot: QQ图                                           ║
╚════════════════════════════════════════════════════════════╝
")
