# Gene Expression Heatmap Example
# Template for visualizing differential gene expression data

library(ComplexHeatmap)
library(circlize)

# Set seed for reproducibility
set.seed(456)

# ==============================================================================
# 1. SIMULATE/LOAD DATA
# ==============================================================================
cat("Step 1: Loading data...\n")

# Simulate gene expression matrix (genes x samples)
# In practice, load your own data:
# expr_mat <- read.table("expression_data.txt", header=TRUE, row.names=1)

n_genes <- 50
n_samples <- 20

expr_mat <- matrix(rnorm(n_genes * n_samples, mean = 5, sd = 2), 
                   nrow = n_genes, 
                   ncol = n_samples)
rownames(expr_mat) <- paste0("Gene", 1:n_genes)
colnames(expr_mat) <- paste0("Sample", 1:n_samples)

cat(sprintf("  Expression matrix: %d genes x %d samples\n", n_genes, n_samples))

# ==============================================================================
# 2. SAMPLE METADATA
# ==============================================================================
cat("\nStep 2: Preparing sample metadata...\n")

sample_metadata <- data.frame(
    sample_id = colnames(expr_mat),
    group = c(rep("Control", 10), rep("Treatment", 10)),
    batch = rep(c("Batch1", "Batch2"), each = 10),
    replicate = rep(1:10, times = 2)
)

cat("  Sample groups:\n")
print(table(sample_metadata$group))

# ==============================================================================
# 3. DATA NORMALIZATION
# ==============================================================================
cat("\nStep 3: Normalizing data (Z-score)...\n")

# Z-score normalization (row-wise)
expr_scaled <- t(scale(t(expr_mat)))

cat("  Z-score range:", range(expr_scaled, na.rm = TRUE), "\n")

# ==============================================================================
# 4. CREATE COLUMN ANNOTATION
# ==============================================================================
cat("\nStep 4: Creating column annotations...\n")

col_anno <- HeatmapAnnotation(
    Group = sample_metadata$group,
    Batch = sample_metadata$batch,
    
    # Color mappings
    col = list(
        Group = c("Control" = "#4DBBD5FF", "Treatment" = "#E64B35FF"),
        Batch = c("Batch1" = "#00A087FF", "Batch2" = "#3C5488FF")
    ),
    
    # Annotation settings
    annotation_name_side = "left",
    annotation_name_gp = gpar(fontsize = 10),
    gap = unit(1, "mm")
)

# ==============================================================================
# 5. CREATE HEATMAP
# ==============================================================================
cat("\nStep 5: Creating heatmap...\n")

ht <- Heatmap(
    expr_scaled,
    name = "Z-score",
    
    # =========================================================================
    # Color scheme
    # =========================================================================
    col = colorRamp2(
        breaks = c(-2, 0, 2),
        colors = c("#2166AC", "white", "#B2182B")
    ),
    
    # =========================================================================
    # Clustering parameters
    # =========================================================================
    cluster_rows = TRUE,
    cluster_columns = TRUE,
    clustering_distance_rows = "euclidean",
    clustering_distance_columns = "euclidean",
    clustering_method_rows = "complete",
    clustering_method_columns = "complete",
    
    # Show dendrograms
    show_row_dend = TRUE,
    show_column_dend = TRUE,
   row_dend_width = unit(2, "cm"),
    column_dend_height = unit(2, "cm"),
    
    # =========================================================================
    # Splitting Options
    # =========================================================================
    # Split rows into 2 groups (up/down-regulated)
    row_split = 2,
    row_gap = unit(2, "mm"),
    border = TRUE,
    
    # =========================================================================
    # Display options
    # =========================================================================
    show_row_names = TRUE,   # Set FALSE for many genes
    show_column_names = TRUE,
    
    row_names_gp = gpar(fontsize = 8),
    column_names_gp = gpar(fontsize = 9),
    column_names_rot = 45,
    row_names_side = "right",
    
    # =========================================================================
    # Annotations
    # =========================================================================
    top_annotation = col_anno,
    
    # =========================================================================
    # Titles
    # =========================================================================
    column_title = "Samples",
    column_title_gp = gpar(fontsize = 14, fontface = "bold"),
    row_title = "Differentially Expressed Genes",
    row_title_gp = gpar(fontsize = 12),
    
    # =========================================================================
    # Size
    # =========================================================================
    width = unit(12, "cm"),
    height = unit(16, "cm"),
    
    # =========================================================================
    # Legend customization
    # =========================================================================
    heatmap_legend_param = list(
        title_gp = gpar(fontsize = 11, fontface = "bold"),
        labels_gp = gpar(fontsize = 9),
        legend_height = unit(4, "cm"),
        border = "black"
    )
)

# ==============================================================================
# 6. SAVE OUTPUTS
# ==============================================================================
cat("\nStep 6: Saving outputs...\n")

# Save as PNG (preview)
png("gene_expression_heatmap.png", width = 1400, height = 1600, res = 150)
draw(ht, heatmap_legend_side = "right", annotation_legend_side = "bottom")
dev.off()
cat("  Saved: gene_expression_heatmap.png\n")

# Save as PDF (publication quality)
pdf("gene_expression_heatmap.pdf", width = 12, height = 14)
draw(ht, heatmap_legend_side = "right", annotation_legend_side = "bottom")
dev.off()
cat("  Saved: gene_expression_heatmap.pdf\n")

# ==============================================================================
# 7. OPTIONAL: Export clustered matrix
# ==============================================================================
cat("\nStep 7: Exporting clustered data...\n")

# Get row and column order after clustering
row_order <- row_order(ht)
col_order <- column_order(ht)

# Export reordered matrix
expr_clustered <- expr_scaled[unlist(row_order), col_order]

write.table(expr_clustered, 
            "gene_expression_clustered.txt",
            sep = "\t",
            quote = FALSE)

cat("  Saved: gene_expression_clustered.txt\n")

# ==============================================================================
# SUMMARY
# ==============================================================================
cat("\n================================================\n")
cat("Gene Expression Heatmap Analysis Complete!\n")
cat("================================================\n")
cat("\nOutput files:\n")
cat("  1. gene_expression_heatmap.png (preview)\n")
cat("  2. gene_expression_heatmap.pdf (publication)\n")
cat("  3. gene_expression_clustered.txt (data)\n")
cat("\nParameters used:\n")
cat("  - Normalization: Z-score (row-wise)\n")
cat("  - Clustering: Euclidean distance, Complete linkage\n")
cat("  - Row splits: 2 (k-means)\n")
cat("  - Color scheme: Blue-White-Red diverging\n")
cat("\nNext steps:\n")
cat("  - Adjust row_split for desired number of gene clusters\n")
cat("  - Modify clustering parameters if needed\n")
cat("  - Add row annotations for gene pathways\n")
cat("  - Filter to top N variable genes for cleaner visualization\n")
