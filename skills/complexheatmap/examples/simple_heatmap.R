# Simple Heatmap Example
# Basic demonstration of ComplexHeatmap functionality

library(ComplexHeatmap)
library(circlize)

# Set seed for reproducibility
set.seed(123)

# Generate example data
mat <- matrix(rnorm(100), 10, 10)
rownames(mat) <- paste0("Gene", 1:10)
colnames(mat) <- paste0("Sample", 1:10)

cat("Created example matrix:\n")
cat("Dimensions:", dim(mat), "\n")
cat("Range:", range(mat), "\n\n")

# ==============================================================================
# Example 1: Simplest heatmap
# ==============================================================================
cat("Example 1: Creating simplest heatmap...\n")

png("example1_simple.png", width = 800, height = 800, res = 120)
Heatmap(mat)
dev.off()

cat("Saved: example1_simple.png\n\n")

# ==============================================================================
# Example 2: Heatmap with basic customization
# ==============================================================================
cat("Example 2: Heatmap with customization...\n")

png("example2_custom.png", width = 1000, height = 1000, res = 120)
Heatmap(
    mat,
    name = "Expression",  # Legend title
    
    # Color mapping
    col = colorRamp2(c(-2, 0, 2), c("blue", "white", "red")),
    
    # Clustering
    cluster_rows = TRUE,
    cluster_columns = TRUE,
    
    # Display options
    show_row_names = TRUE,
    show_column_names = TRUE,
    row_names_gp = gpar(fontsize = 10),
    column_names_gp = gpar(fontsize = 10),
    column_names_rot = 45
)
dev.off()

cat("Saved: example2_custom.png\n\n")

# ==============================================================================
# Example 3: Heatmap with cell borders
# ==============================================================================
cat("Example 3: Heatmap with cell borders...\n")

png("example3_borders.png", width = 1000, height = 1000, res = 120)
Heatmap(
    mat,
    name = "Value",
    col = colorRamp2(c(-2, 0, 2), c("green", "black", "red")),
    
    # Add white borders between cells
    rect_gp = gpar(col = "white", lwd = 2),
    
    # Cell dimensions
    width = unit(8, "cm"),
    height = unit(8, "cm")
)
dev.off()

cat("Saved: example3_borders.png\n\n")

# ==============================================================================
# Example 4: Heatmap with values displayed in cells
# ==============================================================================
cat("Example 4: Heatmap with cell values...\n")

png("example4_values.png", width = 1000, height = 1000, res = 120)
Heatmap(
    mat,
    name = "Value",
    col = colorRamp2(c(-2, 0, 2), c("#2166AC", "white", "#B2182B")),
    
    # Display rounded values in each cell
    cell_fun = function(j, i, x, y, width, height, fill) {
        grid.text(sprintf("%.1f", mat[i, j]), x, y, 
                  gp = gpar(fontsize = 9))
    },
    
    # Styling
    row_names_gp = gpar(fontsize = 10),
    column_names_gp = gpar(fontsize = 10),
    column_names_rot = 45
)
dev.off()

cat("Saved: example4_values.png\n\n")

# ==============================================================================
# Example 5: Heatmap without clustering
# ==============================================================================
cat("Example 5: Heatmap without clustering (original order)...\n")

png("example5_no_cluster.png", width = 1000, height = 1000, res = 120)
Heatmap(
    mat,
    name = "Value",
    col = colorRamp2(c(-2, 0, 2), c("purple", "white", "orange")),
    
    # Disable clustering
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    
    # Show original row/column order
    row_names_gp = gpar(fontsize = 10),
    column_names_gp = gpar(fontsize = 10)
)
dev.off()

cat("Saved: example5_no_cluster.png\n\n")

# ==============================================================================
# Example 6: Save as high-quality PDF
# ==============================================================================
cat("Example 6: Saving as publication-quality PDF...\n")

# Create the heatmap object
ht <- Heatmap(
    mat,
    name = "Expression",
    col = colorRamp2(c(-2, 0, 2), c("blue", "white", "red")),
    cluster_rows = TRUE,
    cluster_columns = TRUE,
    show_row_names = TRUE,
    show_column_names = TRUE,
    row_names_gp = gpar(fontsize = 10),
    column_names_gp = gpar(fontsize = 10),
    column_names_rot = 45,
    
    # Legend customization
    heatmap_legend_param = list(
        title_gp = gpar(fontsize = 11, fontface = "bold"),
        labels_gp = gpar(fontsize = 9)
    )
)

# Save as PDF (vector format, publication-quality)
pdf("example6_publication.pdf", width = 8, height = 8)
draw(ht, heatmap_legend_side = "right")
dev.off()

cat("Saved: example6_publication.pdf\n\n")

# ==============================================================================
# Summary
# ==============================================================================
cat("================================================\n")
cat("All examples completed successfully!\n")
cat("================================================\n")
cat("Generated files:\n")
cat("  - example1_simple.png\n")
cat("  - example2_custom.png\n")
cat("  - example3_borders.png\n")
cat("  - example4_values.png\n")
cat("  - example5_no_cluster.png\n")
cat("  - example6_publication.pdf\n")
cat("\n")
cat("Next steps:\n")
cat("  1. Try modifying the color schemes\n")
cat("  2. Experiment with different clustering methods\n")
cat("  3. Add annotations (see gene_expression_heatmap.R)\n")
cat("  4. Explore advanced features (see references/)\n")
