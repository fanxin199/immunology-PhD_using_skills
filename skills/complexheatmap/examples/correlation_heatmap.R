# Correlation Matrix Heatmap Example

library(ComplexHeatmap)
library(circlize)

set.seed(789)

# Generate example data
n <- 20
data_mat <- matrix(rnorm(n * 50), ncol = n)
colnames(data_mat) <- paste0("Feature", 1:n)

# Calculate correlation matrix
cor_mat <- cor(data_mat, method = "pearson")

cat("Correlation matrix dimensions:", dim(cor_mat), "\n")
cat("Correlation range:", range(cor_mat), "\n\n")

# Create heatmap
ht <- Heatmap(
    cor_mat,
    name = "Correlation",
    
    # Diverging color scheme (centered at 0)
    col = colorRamp2(
        breaks = c(-1, -0.5, 0, 0.5, 1),
        colors = c("#4575B4", "#91BFDB", "white", "#FC8D59", "#D73027")
    ),
    
    # Clustering (symmetric for correlation matrix)
    cluster_rows = TRUE,
    cluster_columns = TRUE,
    clustering_distance_rows = "euclidean",
    clustering_method_rows = "average",
    
    # Display
    show_row_names = TRUE,
    show_column_names = TRUE,
    row_names_gp = gpar(fontsize = 9),
    column_names_gp = gpar(fontsize = 9),
    column_names_rot = 45,
    
    # Cell borders
    rect_gp = gpar(col = "white", lwd = 1.5),
    
    # Add correlation values
    cell_fun = function(j, i, x, y, width, height, fill) {
        grid.text(sprintf("%.2f", cor_mat[i, j]), x, y, 
                  gp = gpar(fontsize = 7))
    },
    
    # Make square cells
    width = ncol(cor_mat) * unit(8, "mm"),
    height = nrow(cor_mat) * unit(8, "mm"),
    
    # Legend
    heatmap_legend_param = list(
        title_gp = gpar(fontsize = 11, fontface = "bold"),
        at = c(-1, -0.5, 0, 0.5, 1),
        labels = c("-1.0", "-0.5", "0.0", "0.5", "1.0"),
        legend_height = unit(4, "cm"),
        border = "black"
    )
)

# Save
pdf("correlation_heatmap.pdf", width = 10, height = 10)
draw(ht, heatmap_legend_side = "right")
dev.off()

png("correlation_heatmap.png", width = 1200, height = 1200, res = 120)
draw(ht, heatmap_legend_side = "right")
dev.off()

cat("Saved correlation heatmaps successfully!\n")
