# Multiple Heatmap Integration Example
# Demonstrates horizontal concatenation of heatmaps

library(ComplexHeatmap)
library(circlize)

set.seed(111)

# Generate three related data matrices (same genes, same samples)
n_genes <- 40
n_samples <- 15

expr_mat <- matrix(rnorm(n_genes * n_samples, mean = 5, sd = 2), 
                   nrow = n_genes, ncol = n_samples)
meth_mat <- matrix(runif(n_genes * n_samples, 0, 1), 
                   nrow = n_genes, ncol = n_samples)
cnv_mat <- matrix(sample(c(-1, 0, 1), n_genes * n_samples, 
                         replace = TRUE, prob = c(0.1, 0.8, 0.1)),
                  nrow = n_genes, ncol = n_samples)

rownames(expr_mat) <- rownames(meth_mat) <- rownames(cnv_mat) <- paste0("Gene", 1:n_genes)
colnames(expr_mat) <- colnames(meth_mat) <- colnames(cnv_mat) <- paste0("Sample", 1:n_samples)

cat("Created three data matrices:\n")
cat("  Expression:", dim(expr_mat), "\n")
cat("  Methylation:", dim(meth_mat), "\n")
cat("  CNV:", dim(cnv_mat), "\n\n")

# Sample annotation (shared across all heatmaps)
sample_groups <- c(rep("Control", 7), rep("Treatment", 8))

col_anno <- HeatmapAnnotation(
    Group = sample_groups,
    col = list(Group = c("Control" = "#00A087", "Treatment" = "#DC0000")),
    annotation_name_side = "left",
    annotation_name_gp = gpar(fontsize = 10)
)

# ============================================================================
# Heatmap 1: Gene Expression
# ============================================================================
ht_expr <- Heatmap(
    t(scale(t(expr_mat))),  # Z-score
    name = "Expression\nZ-score",
    
    # Color
    col = colorRamp2(c(-2, 0, 2), c("green", "black", "red")),
    
    # Clustering (this is the "main" heatmap)
    cluster_rows = TRUE,
    cluster_columns = TRUE,
    clustering_distance_rows = "euclidean",
    clustering_method_rows = "ward.D2",
    show_row_dend = TRUE,
    show_column_dend = TRUE,
    column_dend_height = unit(2, "cm"),
    
    # Display
    show_row_names = TRUE,
    show_column_names = FALSE,
    row_names_gp = gpar(fontsize = 8),
    
    # Annotation
    top_annotation = col_anno,
    
    # Size
    width = unit(6, "cm"),
    
    # Title
    column_title = "Expression",
    column_title_gp = gpar(fontsize = 12, fontface = "bold")
)

# ============================================================================
# Heatmap 2: DNA Methylation
# ============================================================================
ht_meth <- Heatmap(
    meth_mat,
    name = "Methylation\nBeta",
    
    # Color (sequential, 0 to 1)
    col = colorRamp2(c(0, 0.5, 1), c("white", "yellow", "red")),
    
    # Clustering (will match ht_expr automatically)
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    show_row_names = FALSE,
    show_column_names = FALSE,
    
    # Size
    width = unit(6, "cm"),
    
    # Title
    column_title = "Methylation",
    column_title_gp = gpar(fontsize = 12, fontface = "bold")
)

# ============================================================================
# Heatmap 3: Copy Number Variation
# ============================================================================
ht_cnv <- Heatmap(
    cnv_mat,
    name = "CNV",
    
    # Color (categorical)
    col = c("-1" = "blue", "0" = "white", "1" = "red"),
    
    # Clustering (will match ht_expr automatically)
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    show_row_names = FALSE,
    show_column_names = FALSE,
    
    # Size
    width = unit(3, "cm"),
    
    # Title
    column_title = "CNV",
    column_title_gp = gpar(fontsize = 12, fontface = "bold")
)

# ============================================================================
# Combine heatmaps horizontally
# ============================================================================
cat("Combining heatmaps...\n")

ht_list <- ht_expr + ht_meth + ht_cnv

# ============================================================================
# Save combined heatmap
# ============================================================================
cat("Saving multi-heatmap figure...\n")

pdf("multi_heatmap.pdf", width = 16, height = 12)
draw(ht_list, 
     main_heatmap = "Expression\nZ-score",  # Specify main heatmap
     heatmap_legend_side = "right",
     annotation_legend_side = "bottom")
dev.off()

png("multi_heatmap.png", width = 1800, height = 1400, res = 120)
draw(ht_list, 
     main_heatmap = "Expression\nZ-score",
     heatmap_legend_side = "right",
     annotation_legend_side = "bottom")
dev.off()

cat("\n================================================\n")
cat("Multi-omics heatmap created successfully!\n")
cat("================================================\n")
cat("Output files:\n")
cat("  - multi_heatmap.pdf\n")
cat("  - multi_heatmap.png\n")
cat("\nFeatures demonstrated:\n")
cat("  - Horizontal concatenation with '+' operator\n")
cat("  - Shared column annotation across heatmaps\n")
cat("  - Synchronized row ordering (from main heatmap)\n")
cat("  - Multiple color schemes (diverging, sequential, categorical)\n")
cat("\nNext steps:\n")
cat("  - Add row annotations (e.g., gene pathways)\n")
cat("  - Try vertical concatenation with '%v%'\n")
cat("  - Experiment with different clustering parameters\n")
