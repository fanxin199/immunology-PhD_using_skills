# ============================================================
# BioViz Pro - 通用辅助函数库
# 包含所有模板共用的工具函数
# ============================================================

library(ggplot2)
library(ggsci)
library(ggpubr)
library(svglite)

# ============================================================
# 发表级图形保存函数（核心）
# ============================================================
#' 保存发表级图形
#' @param plot_obj ggplot对象
#' @param filename 文件名（不含扩展名）
#' @param width 宽度（英寸）
#' @param height 高度（英寸）
#' @param dpi PNG分辨率
#' @param output_dir 输出目录
save_publication_figure <- function(plot_obj, 
                                     filename, 
                                     width = 7, 
                                     height = 6, 
                                     dpi = 300,
                                     output_dir = "figures") {
  
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    message(paste0("📁 创建目录: ", output_dir))
  }
  
  # SVG 矢量图（推荐期刊投稿）
  svg_path <- file.path(output_dir, paste0(filename, ".svg"))
  ggsave(svg_path, plot_obj, width = width, height = height, 
         device = svglite::svglite)
  
  # 高清 PNG（PPT/网页使用）
  png_path <- file.path(output_dir, paste0(filename, ".png"))
  ggsave(png_path, plot_obj, width = width, height = height, 
         dpi = dpi, bg = "white")
  
  # PDF 矢量图（备用）
  pdf_path <- file.path(output_dir, paste0(filename, ".pdf"))
  ggsave(pdf_path, plot_obj, width = width, height = height, 
         device = cairo_pdf)
  
  message(paste0("✅ 已保存: ", filename, " (.svg, .png, .pdf)"))
  
  invisible(list(svg = svg_path, png = png_path, pdf = pdf_path))
}

# ============================================================
# 期刊尺寸常量
# ============================================================
FIGURE_SIZES <- list(
  nature_single = list(width = 3.5, height = 3),
  nature_double = list(width = 7.2, height = 5),
  science_single = list(width = 3.5, height = 3),
  science_double = list(width = 7, height = 5),
  cell_single = list(width = 3.35, height = 3),
  cell_double = list(width = 6.85, height = 5),
  standard = list(width = 7, height = 6),
  square = list(width = 6, height = 6),
  wide = list(width = 10, height = 5)
)

# ============================================================
# 配色方案获取函数
# ============================================================
#' 获取期刊配色
#' @param journal 期刊名称
#' @param n 颜色数量
get_journal_colors <- function(journal = "npg", n = 10) {
  switch(tolower(journal),
    "npg" = pal_npg("nrc")(n),
    "nature" = pal_npg("nrc")(n),
    "aaas" = pal_aaas("default")(n),
    "science" = pal_aaas("default")(n),
    "nejm" = pal_nejm("default")(min(n, 8)),
    "lancet" = pal_lancet("lanonc")(min(n, 9)),
    "jama" = pal_jama("default")(min(n, 7)),
    "jco" = pal_jco("default")(n),
    "bmj" = pal_bmj("default")(min(n, 9)),
    "ucscgb" = pal_ucscgb("default")(n),
    pal_npg("nrc")(n)  # 默认NPG
  )
}

#' 获取上调/下调/无显著差异的三色配色
#' @param journal 期刊名称
get_deg_colors <- function(journal = "npg") {
  colors <- get_journal_colors(journal, 10)
  switch(tolower(journal),
    "npg" = c(Up = "#E64B35FF", Down = "#4DBBD5FF", NS = "#999999"),
    "lancet" = c(Up = "#AD002AFF", Down = "#00468BFF", NS = "#999999"),
    "nejm" = c(Up = "#BC3C29FF", Down = "#0072B5FF", NS = "#999999"),
    "jama" = c(Up = "#DF8F44FF", Down = "#374E55FF", NS = "#999999"),
    c(Up = colors[1], Down = colors[4], NS = "#999999")
  )
}

# ============================================================
# 发表级主题
# ============================================================
#' 发表级主题（基于 ggpubr）
theme_bioviz <- function(base_size = 12, base_family = "Arial") {
  theme_pubr(base_size = base_size, base_family = base_family) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = base_size + 2),
      plot.subtitle = element_text(hjust = 0.5, color = "grey40"),
      axis.title = element_text(face = "bold"),
      legend.title = element_text(face = "bold"),
      strip.text = element_text(face = "bold")
    )
}

# ============================================================
# 数据处理辅助函数
# ============================================================
#' 添加差异表达分类
#' @param data 差异表达数据框
#' @param log2fc_col log2FoldChange列名
#' @param padj_col padj列名
#' @param log2fc_cutoff 阈值
#' @param padj_cutoff p值阈值
add_regulation_label <- function(data, 
                                  log2fc_col = "log2FoldChange",
                                  padj_col = "padj",
                                  log2fc_cutoff = 1,
                                  padj_cutoff = 0.05) {
  data$regulation <- ifelse(
    data[[log2fc_col]] >= log2fc_cutoff & data[[padj_col]] < padj_cutoff, "Up",
    ifelse(
      data[[log2fc_col]] <= -log2fc_cutoff & data[[padj_col]] < padj_cutoff, "Down",
      "NS"
    )
  )
  data$regulation <- factor(data$regulation, levels = c("Up", "Down", "NS"))
  return(data)
}

# ============================================================
# 快速绘图函数
# ============================================================
#' 快速绘制火山图
#' @param data DESeq2/edgeR/limma结果
#' @param journal 期刊配色
quick_volcano <- function(data, 
                           x = "log2FoldChange", 
                           y = "pvalue",
                           journal = "npg",
                           log2fc_cutoff = 1,
                           padj_cutoff = 0.05) {
  
  colors <- get_deg_colors(journal)
  
  # 添加分类
  data <- add_regulation_label(data, x, "padj", log2fc_cutoff, padj_cutoff)
  
  ggplot(data, aes_string(x = x, y = paste0("-log10(", y, ")"), color = "regulation")) +
    geom_point(alpha = 0.6, size = 1.5) +
    geom_vline(xintercept = c(-log2fc_cutoff, log2fc_cutoff), 
               linetype = "dashed", color = "grey50") +
    geom_hline(yintercept = -log10(padj_cutoff), 
               linetype = "dashed", color = "grey50") +
    scale_color_manual(values = colors) +
    labs(x = expression(log[2]~"(Fold Change)"),
         y = expression(-log[10]~"(P-value)"),
         color = "Regulation") +
    theme_bioviz()
}

message("
╔════════════════════════════════════════════════════════════╗
║  BioViz Pro 辅助函数库已加载                               ║
║                                                            ║
║  核心函数：                                                ║
║  - save_publication_figure()  发表级图形保存               ║
║  - get_journal_colors()       获取期刊配色                 ║
║  - get_deg_colors()           获取差异表达配色             ║
║  - theme_bioviz()             发表级主题                   ║
║  - quick_volcano()            快速火山图                   ║
║                                                            ║
║  使用方法：source('scripts/utils.R')                       ║
╚════════════════════════════════════════════════════════════╝
")
