# ============================================================
# BioViz Pro - MA图 (MA Plot / Bland-Altman Plot) 模板
# 
# 用途：展示差异表达分析中基因表达均值与变化幅度的关系
# 输入：差异表达分析结果（baseMean, log2FoldChange, padj）
# 输出：发表级MA图 (SVG/PNG/PDF)
# 
# 作者：BioViz Pro
# 更新日期：2024
# ============================================================

# ====================
# 1. 加载必要的包
# ====================
library(ggplot2)
library(ggsci)
library(ggpubr)
library(svglite)
library(dplyr)

# ====================
# 2. 发表级图形保存函数
# ====================
save_publication_figure <- function(plot_obj, 
                                     filename, 
                                     width = 7, 
                                     height = 6, 
                                     dpi = 300,
                                     output_dir = "figures") {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  
  ggsave(file.path(output_dir, paste0(filename, ".svg")),
         plot_obj, width = width, height = height, device = svglite::svglite)
  ggsave(file.path(output_dir, paste0(filename, ".png")),
         plot_obj, width = width, height = height, dpi = dpi, bg = "white")
  ggsave(file.path(output_dir, paste0(filename, ".pdf")),
         plot_obj, width = width, height = height, device = cairo_pdf)
  
  message(paste0("✅ 图形已保存: ", output_dir, "/", filename))
}

# ====================
# 3. 模拟示例数据
# ====================
set.seed(123)
n_genes <- 5000

# 创建模拟DESeq2输出数据
ma_data <- data.frame(
  gene_id = paste0("Gene_", 1:n_genes),
  baseMean = 10^runif(n_genes, 0, 5),  # 表达均值（对数尺度模拟）
  log2FoldChange = rnorm(n_genes, mean = 0, sd = 1.2),
  pvalue = 10^(-runif(n_genes, 0, 8)),
  stringsAsFactors = FALSE
)

# 添加校正后p值
ma_data$padj <- p.adjust(ma_data$pvalue, method = "BH")

# ====================
# 4. 数据预处理
# ====================
# 定义差异阈值
log2FC_cutoff <- 1
padj_cutoff <- 0.05

# 添加差异表达分类
ma_data <- ma_data %>%
  mutate(
    regulation = case_when(
      log2FoldChange >= log2FC_cutoff & padj < padj_cutoff ~ "上调 (Up)",
      log2FoldChange <= -log2FC_cutoff & padj < padj_cutoff ~ "下调 (Down)",
      TRUE ~ "无显著差异 (NS)"
    ),
    regulation = factor(regulation, 
                        levels = c("上调 (Up)", "下调 (Down)", "无显著差异 (NS)"))
  )

# 统计
reg_summary <- ma_data %>% count(regulation)
print(reg_summary)

# ====================
# 5. 绑制MA图 - Nature (NPG) 风格
# ====================
ma_plot_npg <- ggplot(ma_data, aes(x = log10(baseMean), 
                                    y = log2FoldChange, 
                                    color = regulation)) +
  # 绑制散点
  geom_point(alpha = 0.5, size = 1.2) +
  
  # 添加参考线
  geom_hline(yintercept = 0, linetype = "solid", color = "grey30", linewidth = 0.5) +
  geom_hline(yintercept = c(-log2FC_cutoff, log2FC_cutoff), 
             linetype = "dashed", color = "grey50", linewidth = 0.4) +
  
  # Nature 配色
  scale_color_manual(
    values = c("上调 (Up)" = "#E64B35FF",       # NPG红
               "下调 (Down)" = "#4DBBD5FF",     # NPG蓝
               "无显著差异 (NS)" = "#AAAAAA")
  ) +
  
  # 标题和标签
  labs(
    title = "MA Plot - 差异表达基因分布",
    subtitle = paste0("上调: ", reg_summary$n[reg_summary$regulation == "上调 (Up)"],
                      " | 下调: ", reg_summary$n[reg_summary$regulation == "下调 (Down)"]),
    x = expression(log[10]~"(Mean Expression)"),
    y = expression(log[2]~"(Fold Change)"),
    color = "表达变化"
  ) +
  
  # 发表级主题
  theme_pubr(base_size = 12, base_family = "Arial") +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 10, color = "grey40"),
    legend.position = "right",
    legend.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold")
  ) +
  
  # 坐标轴设置
  scale_y_continuous(limits = c(-5, 5), breaks = seq(-4, 4, 2))

# 显示图形
print(ma_plot_npg)

# ====================
# 6. 保存发表级图形
# ====================
save_publication_figure(ma_plot_npg, "ma_plot_NPG", width = 7, height = 5.5)

# ====================
# 7. 其他期刊配色变体
# ====================

# Lancet 风格
ma_plot_lancet <- ma_plot_npg +
  scale_color_manual(
    values = c("上调 (Up)" = "#AD002AFF",
               "下调 (Down)" = "#00468BFF",
               "无显著差异 (NS)" = "#AAAAAA")
  )
save_publication_figure(ma_plot_lancet, "ma_plot_Lancet", width = 7, height = 5.5)

# AAAS (Science) 风格
ma_plot_aaas <- ma_plot_npg +
  scale_color_manual(
    values = c("上调 (Up)" = "#EE0000FF",
               "下调 (Down)" = "#3B4992FF",
               "无显著差异 (NS)" = "#AAAAAA")
  )
save_publication_figure(ma_plot_aaas, "ma_plot_AAAS", width = 7, height = 5.5)

# JCO (临床肿瘤学) 风格
ma_plot_jco <- ma_plot_npg +
  scale_color_manual(
    values = c("上调 (Up)" = "#DF8F44FF",
               "下调 (Down)" = "#0073C2FF",
               "无显著差异 (NS)" = "#AAAAAA")
  )
save_publication_figure(ma_plot_jco, "ma_plot_JCO", width = 7, height = 5.5)

# ====================
# 8. 添加密度轮廓的高级版本
# ====================
ma_plot_density <- ggplot(ma_data, aes(x = log10(baseMean), y = log2FoldChange)) +
  # 密度轮廓（显示数据分布）
  geom_density_2d(color = "grey60", linewidth = 0.3) +
  
  # 散点图层
  geom_point(aes(color = regulation), alpha = 0.4, size = 1) +
  
  # 参考线
  geom_hline(yintercept = 0, linetype = "solid", color = "grey30", linewidth = 0.5) +
  geom_hline(yintercept = c(-log2FC_cutoff, log2FC_cutoff), 
             linetype = "dashed", color = "#666666", linewidth = 0.4) +
  
  # NPG配色
  scale_color_manual(
    values = c("上调 (Up)" = "#E64B35FF",
               "下调 (Down)" = "#4DBBD5FF",
               "无显著差异 (NS)" = "#CCCCCC")
  ) +
  
  labs(
    title = "MA Plot with Density Contours",
    x = expression(log[10]~"(Mean Expression)"),
    y = expression(log[2]~"(Fold Change)"),
    color = "表达变化"
  ) +
  
  theme_pubr(base_size = 12) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "right"
  )

save_publication_figure(ma_plot_density, "ma_plot_density", width = 7, height = 5.5)

# ====================
# 9. 使用说明
# ====================
message("
╔════════════════════════════════════════════════════════════╗
║  MA图绑制完成！                                            ║
║                                                            ║
║  MA图用途：                                                ║
║  - 展示基因表达水平与变化幅度的关系                        ║
║  - 识别低表达基因的高变异性（漏斗效应）                    ║
║  - 检查差异分析的系统性偏差                                ║
║                                                            ║
║  输出文件位于 figures/ 目录                                ║
╚════════════════════════════════════════════════════════════╝
")
