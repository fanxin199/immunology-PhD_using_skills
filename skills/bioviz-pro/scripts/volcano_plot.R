# ============================================================
# BioViz Pro - 火山图 (Volcano Plot) 模板
# 
# 用途：展示差异表达基因分析结果
# 输入：差异表达分析结果（log2FoldChange, pvalue/padj）
# 输出：发表级火山图 (SVG/PNG/PDF)
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
library(ggrepel)
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
  
  # SVG 矢量图
  ggsave(file.path(output_dir, paste0(filename, ".svg")),
         plot_obj, width = width, height = height, device = svglite::svglite)
  
  # 高分辨率 PNG
  ggsave(file.path(output_dir, paste0(filename, ".png")),
         plot_obj, width = width, height = height, dpi = dpi, bg = "white")
  
  # PDF 矢量图
  ggsave(file.path(output_dir, paste0(filename, ".pdf")),
         plot_obj, width = width, height = height, device = cairo_pdf)
  
  message(paste0("✅ 图形已保存: ", output_dir, "/", filename))
}

# ====================
# 3. 模拟示例数据（实际使用时替换为您的DESeq2/edgeR结果）
# ====================
set.seed(42)
n_genes <- 5000

# 创建模拟差异表达数据
deg_data <- data.frame(
  gene_id = paste0("Gene_", 1:n_genes),
  gene_name = paste0("Gene_", 1:n_genes),
  log2FoldChange = rnorm(n_genes, mean = 0, sd = 1.5),
  pvalue = 10^(-runif(n_genes, 0, 6)),
  baseMean = runif(n_genes, 10, 10000)
)

# 计算校正后的p值
deg_data$padj <- p.adjust(deg_data$pvalue, method = "BH")

# ====================
# 4. 数据预处理
# ====================
# 定义差异表达阈值
log2FC_cutoff <- 1       # log2FoldChange 阈值
padj_cutoff <- 0.05      # 校正后p值阈值

# 添加差异表达分类标签
deg_data <- deg_data %>%
  mutate(
    regulation = case_when(
      log2FoldChange >= log2FC_cutoff & padj < padj_cutoff ~ "上调 (Up)",
      log2FoldChange <= -log2FC_cutoff & padj < padj_cutoff ~ "下调 (Down)",
      TRUE ~ "无显著差异 (NS)"
    ),
    # 设置因子水平顺序（控制图例顺序和颜色分配）
    regulation = factor(regulation, 
                        levels = c("上调 (Up)", "下调 (Down)", "无显著差异 (NS)"))
  )

# 统计各类别基因数量
reg_summary <- deg_data %>% count(regulation)
print(reg_summary)

# ====================
# 5. 标记重要基因（可选）
# ====================
# 选择最显著的上调和下调基因进行标注
top_genes <- deg_data %>%
  filter(regulation != "无显著差异 (NS)") %>%
  group_by(regulation) %>%
  slice_min(order_by = padj, n = 5) %>%
  ungroup()

# ====================
# 6. 绑制火山图 - Nature 风格
# ====================
volcano_npg <- ggplot(deg_data, aes(x = log2FoldChange, 
                                     y = -log10(pvalue), 
                                     color = regulation)) +
  # 绑制散点
  geom_point(alpha = 0.6, size = 1.5) +
  
  # 添加阈值线
  geom_vline(xintercept = c(-log2FC_cutoff, log2FC_cutoff), 
             linetype = "dashed", color = "grey50", linewidth = 0.5) +
  geom_hline(yintercept = -log10(padj_cutoff), 
             linetype = "dashed", color = "grey50", linewidth = 0.5) +
  
  # 使用 Nature 配色方案
  scale_color_manual(values = c("上调 (Up)" = "#E64B35FF",      # NPG红色
                                 "下调 (Down)" = "#4DBBD5FF",    # NPG蓝色
                                 "无显著差异 (NS)" = "#999999")) +
  
  # 标注重要基因
  geom_text_repel(
    data = top_genes,
    aes(label = gene_name),
    size = 3,
    max.overlaps = 20,
    box.padding = 0.5,
    point.padding = 0.3,
    segment.color = "grey50",
    show.legend = FALSE
  ) +
  
  # 添加标题和轴标签
  labs(
    title = "差异表达基因火山图",
    subtitle = paste0("上调: ", reg_summary$n[reg_summary$regulation == "上调 (Up)"],
                      " | 下调: ", reg_summary$n[reg_summary$regulation == "下调 (Down)"]),
    x = expression(log[2]~"(Fold Change)"),
    y = expression(-log[10]~"(P-value)"),
    color = "表达变化"
  ) +
  
  # 发表级主题设置
  theme_pubr(base_size = 12, base_family = "Arial") +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 10, color = "grey40"),
    legend.position = "right",
    legend.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  ) +
  
  # 设置坐标轴范围
  scale_x_continuous(limits = c(-6, 6), breaks = seq(-6, 6, 2)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05)))

# 显示图形
print(volcano_npg)

# ====================
# 7. 保存发表级图形
# ====================
save_publication_figure(volcano_npg, "volcano_plot_NPG", width = 7, height = 6)

# ====================
# 8. 其他期刊配色变体
# ====================

# Lancet 风格火山图
volcano_lancet <- volcano_npg +
  scale_color_manual(values = c("上调 (Up)" = "#AD002AFF",      # Lancet红色
                                 "下调 (Down)" = "#00468BFF",    # Lancet蓝色
                                 "无显著差异 (NS)" = "#999999"))
save_publication_figure(volcano_lancet, "volcano_plot_Lancet", width = 7, height = 6)

# NEJM 风格火山图
volcano_nejm <- volcano_npg +
  scale_color_manual(values = c("上调 (Up)" = "#BC3C29FF",      # NEJM红色
                                 "下调 (Down)" = "#0072B5FF",    # NEJM蓝色
                                 "无显著差异 (NS)" = "#999999"))
save_publication_figure(volcano_nejm, "volcano_plot_NEJM", width = 7, height = 6)

# JAMA 风格火山图
volcano_jama <- volcano_npg +
  scale_color_manual(values = c("上调 (Up)" = "#DF8F44FF",      # JAMA橙色
                                 "下调 (Down)" = "#374E55FF",    # JAMA蓝灰
                                 "无显著差异 (NS)" = "#999999"))
save_publication_figure(volcano_jama, "volcano_plot_JAMA", width = 7, height = 6)

# ====================
# 9. 使用说明
# ====================
# 使用您自己的数据时：
# 1. 将 deg_data 替换为您的 DESeq2/edgeR/limma 分析结果
# 2. 确保数据框包含：gene_id, log2FoldChange, pvalue (或 padj)
# 3. 根据需要调整 log2FC_cutoff 和 padj_cutoff 阈值
# 4. 选择合适的期刊配色方案
# 5. 运行脚本即可生成 SVG/PNG/PDF 三种格式的图形

message("
╔════════════════════════════════════════════════════════════╗
║  火山图绑制完成！                                          ║
║  输出文件位于 figures/ 目录：                              ║
║  - volcano_plot_NPG.svg/png/pdf (Nature 风格)              ║
║  - volcano_plot_Lancet.svg/png/pdf (Lancet 风格)           ║
║  - volcano_plot_NEJM.svg/png/pdf (NEJM 风格)               ║
║  - volcano_plot_JAMA.svg/png/pdf (JAMA 风格)               ║
╚════════════════════════════════════════════════════════════╝
")
