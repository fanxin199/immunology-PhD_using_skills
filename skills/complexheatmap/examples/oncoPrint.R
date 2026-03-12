# OncoPrint Example
# Genomic alteration visualization

library(ComplexHeatmap)

set.seed(222)

# ============================================================================
# 1. CREATE ALTERATION MATRIX
# ============================================================================
cat("Creating alteration matrix...\n")

# Define genes and samples
genes <- c("TP53", "KRAS", "EGFR", "PTEN", "PIK3CA", "BRAF", "NRAS", "APC", "BRCA1", "BRCA2")
samples <- paste0("Sample", 1:30)

# Initialize empty matrix
mat <- matrix("", nrow = length(genes), ncol = length(samples))
rownames(mat) <- genes
colnames(mat) <- samples

# Simulate alterations (each gene has different alteration frequency)
gene_freq <- c(0.4, 0.3, 0.25, 0.2, 0.3, 0.15, 0.1, 0.35, 0.12, 0.10)  # TP53 highest

for(i in 1:nrow(mat)) {
    for(j in 1:ncol(mat)) {
        x <- runif(1)
        if(x < gene_freq[i] * 0.6) {
            mat[i,j] <- "MUT"
        } else if(x < gene_freq[i] * 0.8) {
            mat[i,j] <- "AMP"
        } else if(x < gene_freq[i] * 0.95) {
            mat[i,j] <- "HOMDEL"
        } else if(x < gene_freq[i]) {
            mat[i,j] <- "MUT;AMP"  # Multiple alterations
        }
    }
}

cat(sprintf("  Matrix: %d genes x %d samples\n", nrow(mat), ncol(mat)))
cat("  Alteration frequencies:\n")
for(i in 1:nrow(mat)) {
    freq <- sum(mat[i,] != "") / ncol(mat) * 100
    cat(sprintf("    %s: %.1f%%\n", genes[i], freq))
}
cat("\n")

# ============================================================================
# 2. DEFINE COLORS AND ALTERATION GRAPHICS
# ============================================================================
cat("Defining alteration types and colors...\n")

col <- c("MUT" = "#008000", "AMP" = "#FF0000", "HOMDEL" = "#0000FF")

alter_fun <- list(
    background = function(x, y, w, h) {
        grid.rect(x, y, w*0.95, h*0.95, 
                  gp = gpar(fill = "#EEEEEE", col = "#CCCCCC", lwd = 0.5))
    },
    MUT = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.9, 
                  gp = gpar(fill = col["MUT"], col = NA))
    },
    AMP = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.35, 
                  gp = gpar(fill = col["AMP"], col = NA))
    },
    HOMDEL = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.35, 
                  gp = gpar(fill = col["HOMDEL"], col = NA))
    }
)

# ============================================================================
# 3. SAMPLE ANNOTATIONS
# ============================================================================
cat("Creating sample annotations...\n")

sample_type <- sample(c("Primary", "Metastasis"), length(samples), replace = TRUE)
sample_response <- sample(c("Responder", "Non-Responder"), length(samples), replace = TRUE)

top_anno <- HeatmapAnnotation(
    Type = sample_type,
    Response = sample_response,
    col = list(
        Type = c("Primary" = "lightblue", "Metastasis" = "darkblue"),
        Response = c("Responder" = "green", "Non-Responder" = "gray")
    ),
    annotation_name_side = "left",
    annotation_name_gp = gpar(fontsize = 9)
)

# ============================================================================
# 4. CREATE ONCOPRINT
# ============================================================================
cat("Creating OncoPrint...\n")

oncoPrint(mat,
    alter_fun = alter_fun,
    col = col,
    
    # Annotations
    top_annotation = top_anno,
    
    # Barplots showing alteration frequencies
    right_annotation = rowAnnotation(
        rbar = anno_oncoprint_barplot(
            border = TRUE,
            height = unit(2, "cm")
        )
    ),
    
    bottom_annotation = HeatmapAnnotation(
        cbar = anno_oncoprint_barplot(
            border = TRUE,
            height = unit(2, "cm")
        )
    ),
    
    # Row ordering (by alteration frequency)
    row_order = order(rowSums(mat != ""), decreasing = TRUE),
    
    # Column ordering (by sample type, then total alterations)
    column_order = order(sample_type, -colSums(mat != "")),
    
    # Display
    show_column_names = TRUE,
    column_names_gp = gpar(fontsize = 7),
    column_names_rot = 90,
    show_row_names = TRUE,
    row_names_side = "left",
    row_names_gp = gpar(fontsize = 11, fontface = "bold.italic"),
    
    # Titles
    column_title = "Genomic Alterations",
    column_title_gp = gpar(fontsize = 14, fontface = "bold"),
    
    # Percentage on left
    show_pct = TRUE,
    pct_side = "right",
    pct_gp = gpar(fontsize = 9),
    
    # Legend
    heatmap_legend_param = list(
        title = "Alterations",
        at = c("MUT", "AMP", "HOMDEL"),
        labels = c("Mutation", "Amplification", "Homozygous Deletion"),
        nrow = 1,
        title_gp = gpar(fontsize = 10, fontface = "bold"),
        labels_gp = gpar(fontsize = 9)
    )
)

# Save as PDF
pdf("oncoPrint.pdf", width = 14, height = 10)
oncoPrint(mat,
    alter_fun = alter_fun,
    col = col,
    top_annotation = top_anno,
    right_annotation = rowAnnotation(
        rbar = anno_oncoprint_barplot(border = TRUE, height = unit(2, "cm"))
    ),
    bottom_annotation = HeatmapAnnotation(
        cbar = anno_oncoprint_barplot(border = TRUE, height = unit(2, "cm"))
    ),
    row_order = order(rowSums(mat != ""), decreasing = TRUE),
    column_order = order(sample_type, -colSums(mat != "")),
    show_column_names = TRUE,
    column_names_gp = gpar(fontsize = 7),
    column_names_rot = 90,
    show_row_names = TRUE,
    row_names_side = "left",
    row_names_gp = gpar(fontsize = 11, fontface = "bold.italic"),
    column_title = "Genomic Alterations",
    column_title_gp = gpar(fontsize = 14, fontface = "bold"),
    show_pct = TRUE,
    heatmap_legend_param = list(
        title = "Alterations",
        at = c("MUT", "AMP", "HOMDEL"),
        labels = c("Mutation", "Amplification", "Homozygous Deletion"),
        nrow = 1
    )
)
dev.off()

# Save as PNG
png("oncoPrint.png", width = 1800, height = 1200, res = 120)
oncoPrint(mat,
    alter_fun = alter_fun,
    col = col,
    top_annotation = top_anno,
    right_annotation = rowAnnotation(
        rbar = anno_oncoprint_barplot(border = TRUE, height = unit(2, "cm"))
    ),
    bottom_annotation = HeatmapAnnotation(
        cbar = anno_oncoprint_barplot(border = TRUE, height = unit(2, "cm"))
    ),
    row_order = order(rowSums(mat != ""), decreasing = TRUE),
    column_order = order(sample_type, -colSums(mat != "")),
    show_column_names = TRUE,
    column_names_gp = gpar(fontsize = 7),
    column_names_rot = 90,
    show_row_names = TRUE,
    row_names_side = "left",
    row_names_gp = gpar(fontsize = 11, fontface = "bold.italic"),
    column_title = "Genomic Alterations",
    column_title_gp = gpar(fontsize = 14, fontface = "bold"),
    show_pct = TRUE
)
dev.off()

cat("\n================================================\n")
cat("OncoPrint created successfully!\n")
cat("================================================\n")
cat("Output files:\n")
cat("  - oncoPrint.pdf\n")
cat("  - oncoPrint.png\n")
cat("\nAlteration summary:\n")
cat(sprintf("  Total samples: %d\n", ncol(mat)))
cat(sprintf("  Total genes: %d\n", nrow(mat)))
cat(sprintf("  Samples with alterations: %d (%.1f%%)\n", 
    sum(colSums(mat != "") > 0),
    sum(colSums(mat != "") > 0) / ncol(mat) * 100))
