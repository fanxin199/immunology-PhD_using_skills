# ============================================================
# BioViz Pro - 表达量热图 (Heatmap) 模板
# 
# 用途：展示基因表达谱、样本聚类分析
# 输入：标准化后的基因表达矩阵
# 输出：发表级热图 (SVG/PNG/PDF)
# 
# 作者：BioViz Pro
# 更新日期：2024
# ============================================================

# ====================
# 1. 加载必要的包
# ====================
library(pheatmap)
library(ComplexHeatmap)  # 高级热图
library(circlize)        # 颜色映射
library(RColorBrewer)
library(ggsci)
library(svglite)
library(dplyr)

# ====================
# 2. 发表级图形保存函数（适用于ComplexHeatmap）
# ====================
save_heatmap_figure <- function(heatmap_obj, 
                                 filename, 
                                 width = 8, 
                                 height = 10, 
                                 dpi = 300,
                                 output_dir = "figures") {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  
  # SVG
  svglite::svglite(file.path(output_dir, paste0(filename, ".svg")), 
                   width = width, height = height)
  draw(heatmap_obj)
  dev.off()
  
  # PNG
  png(file.path(output_dir, paste0(filename, ".png")), 
      width = width, height = height, units = "in", res = dpi)
  draw(heatmap_obj)
  dev.off()
  
  # PDF
  cairo_pdf(file.path(output_dir, paste0(filename, ".pdf")), 
            width = width, height = height)
  draw(heatmap_obj)
  dev.off()
  
  message(paste0("✅ 热图已保存: ", output_dir, "/", filename))
}

# pheatmap 保存函数
save_pheatmap <- function(heatmap_obj, 
                          filename, 
                          width = 8, 
                          height = 10,
                          output_dir = "figures") {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  
  # SVG
  svglite::svglite(file.path(output_dir, paste0(filename, ".svg")), 
                   width = width, height = height)
  print(heatmap_obj)
  dev.off()
  
  # PNG
  png(file.path(output_dir, paste0(filename, ".png")), 
      width = width, height = height, units = "in", res = 300)
  print(heatmap_obj)
  dev.off()
  
  # PDF
  cairo_pdf(file.path(output_dir, paste0(filename, ".pdf")), 
            width = width, height = height)
  print(heatmap_obj)
  dev.off()
  
  message(paste0("✅ 热图已保存: ", output_dir, "/", filename))
}

# ====================
# 3. 模拟示例数据
# ====================
set.seed(42)

# 模拟50个基因，12个样本（6对照 + 6处理）
n_genes <- 50
n_samples <- 12

# 创建基因名称
gene_names <- paste0("Gene_", 1:n_genes)

# 创建样本名称
sample_names <- c(paste0("Control_", 1:6), paste0("Treatment_", 1:6))

# 创建表达矩阵（模拟对照和处理组差异）
expr_matrix <- matrix(rnorm(n_genes * n_samples), nrow = n_genes, ncol = n_samples)
rownames(expr_matrix) <- gene_names
colnames(expr_matrix) <- sample_names

# 人为添加一些差异表达模式
# 前20个基因在处理组中上调
expr_matrix[1:20, 7:12] <- expr_matrix[1:20, 7:12] + 2
# 21-35号基因在处理组中下调
expr_matrix[21:35, 7:12] <- expr_matrix[21:35, 7:12] - 1.5

# 创建样本注释信息
sample_annotation <- data.frame(
  Group = c(rep("Control", 6), rep("Treatment", 6)),
  Batch = rep(c("Batch1", "Batch2"), each = 3, times = 2),
  row.names = sample_names
)

# 创建基因注释信息
gene_annotation <- data.frame(
  Category = c(rep("Upregulated", 20), 
               rep("Downregulated", 15), 
               rep("Unchanged", 15)),
  row.names = gene_names
)

# ====================
# 4. 方法一：使用 pheatmap（简单易用）
# ====================

# 定义 Nature 风格配色
npg_colors <- pal_npg("nrc")(10)

# 样本注释颜色
annotation_colors <- list(
  Group = c(Control = npg_colors[4], Treatment = npg_colors[1]),  # 蓝色/红色
  Batch = c(Batch1 = npg_colors[3], Batch2 = npg_colors[5]),
  Category = c(Upregulated = "#E64B35", Downregulated = "#4DBBD5", Unchanged = "#999999")
)

# 绑制 pheatmap
hm_pheatmap <- pheatmap(
  mat = expr_matrix,
  
  # 聚类设置
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "complete",
  
  # 颜色设置（蓝-白-红渐变）
  color = colorRampPalette(c("#2166AC", "#F7F7F7", "#B2182B"))(100),
  
  # 标准化设置
  scale = "row",  # 按行（基因）标准化
  
  # 注释
  annotation_col = sample_annotation,
  annotation_row = gene_annotation,
  annotation_colors = annotation_colors,
  
  # 显示设置
  show_rownames = TRUE,
  show_colnames = TRUE,
  fontsize = 10,
  fontsize_row = 8,
  fontsize_col = 10,
  
  # 边框
  border_color = NA,
  
  # 图例
  legend = TRUE,
  annotation_legend = TRUE,
  
  # 主标题
  main = "Gene Expression Heatmap\n(Row Z-score Normalized)",
  
  # 不立即绘制，返回对象
  silent = TRUE
)

# 保存 pheatmap
save_pheatmap(hm_pheatmap, "heatmap_pheatmap", width = 10, height = 12)

# ====================
# 5. 方法二：使用 ComplexHeatmap（高级定制）
# ====================

# 设置颜色映射
col_fun <- colorRamp2(
  breaks = c(-2, 0, 2),
  colors = c("#2166AC", "#F7F7F7", "#B2182B")
)

# 行标准化
expr_scaled <- t(scale(t(expr_matrix)))

# 创建顶部注释
ha_top <- HeatmapAnnotation(
  Group = sample_annotation$Group,
  Batch = sample_annotation$Batch,
  col = list(
    Group = c(Control = npg_colors[4], Treatment = npg_colors[1]),
    Batch = c(Batch1 = npg_colors[3], Batch2 = npg_colors[5])
  ),
  annotation_name_side = "left",
  annotation_legend_param = list(
    Group = list(title = "组别"),
    Batch = list(title = "批次")
  )
)

# 创建左侧注释
ha_left <- rowAnnotation(
  Category = gene_annotation$Category,
  col = list(
    Category = c(Upregulated = "#E64B35", 
                 Downregulated = "#4DBBD5", 
                 Unchanged = "#999999")
  ),
  annotation_legend_param = list(
    Category = list(title = "表达变化")
  )
)

# 创建 ComplexHeatmap
hm_complex <- Heatmap(
  matrix = expr_scaled,
  name = "Z-score",
  
  # 颜色
  col = col_fun,
  
  # 聚类
  cluster_rows = TRUE,
  cluster_columns = TRUE,
  clustering_distance_rows = "euclidean",
  clustering_distance_columns = "euclidean",
  clustering_method_rows = "complete",
  clustering_method_columns = "complete",
  
  # 显示树状图
  show_row_dend = TRUE,
  show_column_dend = TRUE,
  row_dend_width = unit(20, "mm"),
  column_dend_height = unit(20, "mm"),
  
  # 标签
  row_names_gp = gpar(fontsize = 8),
  column_names_gp = gpar(fontsize = 10),
  column_names_rot = 45,
  
  # 注释
  top_annotation = ha_top,
  left_annotation = ha_left,
  
  # 边框
  rect_gp = gpar(col = NA),
  
  # 图例
  heatmap_legend_param = list(
    title = "表达水平\n(Z-score)",
    title_position = "topcenter",
    legend_height = unit(4, "cm")
  ),
  
  # 标题
  column_title = "Gene Expression Heatmap",
  column_title_gp = gpar(fontsize = 14, fontface = "bold")
)

# 绘制并保存
save_heatmap_figure(hm_complex, "heatmap_complex", width = 10, height = 12)

# ====================
# 6. 简化版热图（仅显示差异基因）
# ====================

# 选择差异表达基因（前35个）
deg_genes <- gene_names[1:35]
expr_deg <- expr_scaled[deg_genes, ]

hm_deg <- Heatmap(
  matrix = expr_deg,
  name = "Z-score",
  col = col_fun,
  
  cluster_rows = TRUE,
  cluster_columns = TRUE,
  
  show_row_dend = TRUE,
  show_column_dend = TRUE,
  
  row_names_gp = gpar(fontsize = 9),
  column_names_gp = gpar(fontsize = 11),
  column_names_rot = 45,
  
  top_annotation = ha_top,
  
  column_title = "Differentially Expressed Genes",
  column_title_gp = gpar(fontsize = 14, fontface = "bold"),
  
  heatmap_legend_param = list(
    title = "Z-score",
    title_position = "topcenter"
  )
)

save_heatmap_figure(hm_deg, "heatmap_DEGs", width = 8, height = 10)

# ====================
# 7. 使用说明
# ====================
message("
╔════════════════════════════════════════════════════════════╗
║  热图绑制完成！                                            ║
║                                                            ║
║  使用您自己的数据时：                                      ║
║  1. 准备标准化后的表达矩阵（行=基因，列=样本）             ║
║  2. 准备样本注释数据框                                     ║
║  3. 选择 pheatmap（简单）或 ComplexHeatmap（高级）         ║
║  4. 调整颜色方案和聚类参数                                 ║
║                                                            ║
║  推荐配色：                                                ║
║  - 蓝-白-红：适合展示上调/下调                             ║
║  - 紫-白-绿：viridis 色系，适合单向数据                    ║
║                                                            ║
║  输出文件位于 figures/ 目录                                ║
╚════════════════════════════════════════════════════════════╝
")
