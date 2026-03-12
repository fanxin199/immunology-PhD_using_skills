# ============================================================
# BioViz Pro - GO/KEGG 富集分析图模板
# 用途：展示功能富集分析结果（气泡图、柱状图）
# ============================================================

library(ggplot2)
library(ggsci)
library(ggpubr)
library(svglite)
library(dplyr)

# 发表级保存函数
save_publication_figure <- function(plot_obj, filename, width = 8, height = 6, 
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

# 模拟GO/KEGG富集数据
set.seed(42)
enrichment_data <- data.frame(
  Term = c("Cell cycle", "DNA replication", "p53 signaling pathway",
           "Apoptosis", "PI3K-Akt signaling", "MAPK signaling",
           "Wnt signaling", "Notch signaling", "mTOR signaling",
           "Autophagy", "Cell adhesion", "Oxidative phosphorylation"),
  Category = rep(c("KEGG", "GO:BP", "GO:MF"), each = 4),
  Count = sample(10:80, 12),
  GeneRatio = runif(12, 0.05, 0.35),
  pvalue = 10^(-runif(12, 2, 8)),
  FoldEnrichment = runif(12, 1.5, 5)
)
enrichment_data$padj <- p.adjust(enrichment_data$pvalue, method = "BH")
enrichment_data <- enrichment_data %>% arrange(padj)

# ============ 1. 气泡图（Bubble Plot）============
bubble_plot <- ggplot(enrichment_data, 
                       aes(x = GeneRatio, y = reorder(Term, GeneRatio))) +
  geom_point(aes(size = Count, color = -log10(padj)), alpha = 0.8) +
  scale_color_gradient(low = "#4DBBD5", high = "#E64B35",
                       name = expression(-log[10](padj))) +
  scale_size_continuous(range = c(4, 12), name = "Gene Count") +
  labs(title = "Pathway Enrichment Analysis",
       x = "Gene Ratio", y = NULL) +
  theme_pubr(base_size = 11) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
        axis.text.y = element_text(size = 10),
        legend.position = "right")

save_publication_figure(bubble_plot, "enrichment_bubble", width = 9, height = 7)

# ============ 2. 柱状图（按-log10(padj)排序）============
barplot_enrich <- ggplot(enrichment_data %>% head(10), 
                          aes(x = reorder(Term, -log10(padj)), y = -log10(padj))) +
  geom_bar(stat = "identity", aes(fill = Category), alpha = 0.85, width = 0.7) +
  scale_fill_npg() +
  coord_flip() +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "red") +
  labs(title = "Top 10 Enriched Pathways",
       x = NULL, y = expression(-log[10](adjusted~p-value))) +
  theme_pubr(base_size = 11) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        legend.position = "right")

save_publication_figure(barplot_enrich, "enrichment_barplot", width = 9, height = 6)

# ============ 3. 分面气泡图（按类别分组）============
facet_bubble <- ggplot(enrichment_data, 
                        aes(x = FoldEnrichment, y = reorder(Term, FoldEnrichment))) +
  geom_point(aes(size = Count, color = -log10(padj)), alpha = 0.8) +
  facet_grid(Category ~ ., scales = "free_y", space = "free_y") +
  scale_color_gradient(low = "#4DBBD5", high = "#E64B35") +
  scale_size_continuous(range = c(3, 10)) +
  labs(title = "Enrichment by Category", x = "Fold Enrichment", y = NULL) +
  theme_pubr(base_size = 10) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        strip.text = element_text(face = "bold"))

save_publication_figure(facet_bubble, "enrichment_facet", width = 10, height = 8)

message("
╔════════════════════════════════════════════════════════════╗
║  富集分析图绑制完成！                                      ║
║  - enrichment_bubble: 气泡图                               ║
║  - enrichment_barplot: 柱状图                              ║
║  - enrichment_facet: 分面气泡图                            ║
╚════════════════════════════════════════════════════════════╝
")
