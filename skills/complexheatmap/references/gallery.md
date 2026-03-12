# ComplexHeatmap Example Gallery

Real-world examples for common bioinformatics and data visualization scenarios.

## 1. Differential Gene Expression Heatmap

**Scenario**: Visualize top differentially expressed genes from RNA-seq analysis between two conditions.

```r
library(ComplexHeatmap)
library(circlize)

# Assume you have:
# - expr_mat: expression matrix (genes x samples)
# - sample_info: data frame with sample metadata
# - deg_genes: vector of differentially expressed gene names

# Filter to DEGs
deg_mat <- expr_mat[deg_genes, ]

# Z-score normalization (row-wise)
deg_scaled <- t(scale(t(deg_mat)))

# Create sample annotation
col_anno <- HeatmapAnnotation(
    Condition = sample_info$condition,
    Batch = sample_info$batch,
    col = list(
        Condition = c("Control" = "#4DBBD5FF", "Treatment" = "#E64B35FF"),
        Batch = c("Batch1" = "#00A087FF", "Batch2" = "#3C5488FF")
    ),
    annotation_name_side = "left",
    annotation_name_gp = gpar(fontsize = 10)
)

# Create heatmap
ht <- Heatmap(
    deg_scaled,
    name = "Z-score",
    
    # Color scheme
    col = colorRamp2(c(-2, 0, 2), c("#2166AC", "white", "#B2182B")),
    
    # Clustering
   cluster_rows = TRUE,
    cluster_columns = TRUE,
    clustering_distance_rows = "euclidean",
    clustering_method_rows = "complete",
    show_row_dend = TRUE,
    show_column_dend = TRUE,
    row_dend_width = unit(2, "cm"),
    column_dend_height = unit(2, "cm"),
    
    # Split into up/down-regulated genes
    row_split = 2,  # Or use pre-defined groups
    row_gap = unit(2, "mm"),
    border = TRUE,
    
    # Display
    show_row_names = FALSE,  # Too many genes
    show_column_names = TRUE,
    column_names_gp = gpar(fontsize = 10),
    column_names_rot = 45,
    
    # Annotations
    top_annotation = col_anno,
    
    # Titles
    column_title = "Sample Groups",
    column_title_gp = gpar(fontsize = 14, fontface = "bold"),
    row_title = "DEGs (FDR < 0.05, |FC| > 2)",
    row_title_gp = gpar(fontsize = 12),
    
    # Size
    width = unit(12, "cm"),
    height = unit(18, "cm"),
    
    # Legend
    heatmap_legend_param = list(
        title_gp = gpar(fontsize = 11, fontface = "bold"),
        labels_gp = gpar(fontsize = 9),
        legend_height = unit(4, "cm")
    )
)

# Draw and save
pdf("deg_heatmap.pdf", width = 12, height = 14)
draw(ht, heatmap_legend_side = "right")
dev.off()
```

## 2. Pathway Enrichment Heatmap

**Scenario**: Visualize GSEA/GO enrichment results across multiple comparisons.

```r
# Enrichment matrix: pathways x comparisons
# Values: -log10(p-value) * sign(NES)

# Sample data structure:
#                       Comparison1  Comparison2  Comparison3
# Pathway A                   5.2          -3.1          0.8
# Pathway B                  -2.1           6.3          4.5
# ...

# Load enrichment results
# enrich_mat <- read.table("enrichment_results.txt", header=TRUE, row.names=1)

# Prepare matrix
enrich_mat[enrich_mat > 10] <- 10    # Cap values
enrich_mat[enrich_mat < -10] <- -10

# Create column annotation (comparison groups)
comparison_groups <- c("TypeA", "TypeA", "TypeB", "TypeB", "TypeC")

col_anno <- HeatmapAnnotation(
    Group = comparison_groups,
    col = list(Group = c("TypeA" = "#E64B35", "TypeB" = "#4DBBD5", "TypeC" = "#00A087")),
    annotation_name_side = "left"
)

# Create heatmap
ht <- Heatmap(
    enrich_mat,
    name = "-log10(p) × sign(NES)",
    
    # Diverging color (centered at 0)
    col = colorRamp2(
        seq(-10, 10, length.out = 11),
        c("#67001F", "#B2182B", "#D6604D", "#F4A582", "#FDDBC7",
          "white",
          "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC", "#053061")
    ),
    
    # Clustering
    cluster_rows = TRUE,
    cluster_columns = FALSE,  # Keep comparison order
    clustering_distance_rows = "euclidean",
    clustering_method_rows = "ward.D2",
    
    # Display
    show_row_names = TRUE,
    show_column_names = TRUE,
    row_names_gp = gpar(fontsize = 9),
    column_names_gp = gpar(fontsize = 10),
    column_names_rot = 45,
    
    # Cell borders
    rect_gp = gpar(col = "white", lwd = 0.5),
    
    # Mark significant pathways
    cell_fun = function(j, i, x, y, width, height, fill) {
        if(abs(enrich_mat[i, j]) > 5) {  # Highly significant
            grid.text("*", x, y, gp = gpar(fontsize = 16, col = "black"))
        }
    },
    
    # Annotations
    top_annotation = col_anno,
    
    # Titles
    column_title = "Comparisons",
    row_title = "Enriched Pathways",
    
    # Legend
    heatmap_legend_param = list(
        title_gp = gpar(fontsize = 10, fontface = "bold"),
        at = c(-10, -5, 0, 5, 10),
        labels = c("≤-10", "-5", "0", "5", "≥10"),
        legend_height = unit(4, "cm")
    )
)

pdf("pathway_enrichment_heatmap.pdf", width = 10, height = 14)
draw(ht, heatmap_legend_side = "right")
dev.off()
```

## 3. Single-Cell Marker Gene Heatmap

**Scenario**: Visualize marker genes across cell types from scRNA-seq.

```r
# Marker gene expression: genes x cell_types (averaged)
# marker_mat: rows = marker genes, columns = cell types

# Scale expression
marker_scaled <- t(scale(t(marker_mat)))

# Gene to cell type mapping
gene_celltype <- c(rep("T cells", 10), rep("B cells", 8), 
                   rep("Monocytes", 12), rep("NK cells", 7))

# Create row annotation (cell type assignment)
row_anno <- rowAnnotation(
    CellType = gene_celltype,
    col = list(CellType = c(
        "T cells" = "#E64B35",
        "B cells" = "#4DBBD5",
        "Monocytes" = "#00A087",
        "NK cells" = "#3C5488"
    )),
    annotation_name_side = "top",
    width = unit(5, "mm")
)

# Create heatmap
ht <- Heatmap(
    marker_scaled,
    name = "Scaled\nExpression",
    
    # Color
    col = colorRamp2(c(-2, 0, 2), c("purple", "black", "yellow")),
    
    # Clustering
    cluster_rows = FALSE,  # Keep gene order by cell type
    cluster_columns = TRUE,
    show_row_dend = FALSE,
    show_column_dend = TRUE,
    column_dend_height = unit(2, "cm"),
    
    # Split by cell type
    row_split = gene_celltype,
    row_title = "%s markers",
    row_title_gp = gpar(fontsize = 11, fontface = "bold"),
    row_gap = unit(2, "mm"),
    cluster_row_slices = FALSE,
    
    # Display
    show_row_names = TRUE,
    show_column_names = TRUE,
    row_names_gp = gpar(fontsize = 8, fontface = "italic"),
    column_names_gp = gpar(fontsize = 9),
    row_names_side = "left",
    
    # Annotations
    left_annotation = row_anno,
    
    # Titles
    column_title = "Cell Types",
    column_title_gp = gpar(fontsize = 14, fontface = "bold"),
    
    # Legend
    heatmap_legend_param = list(
        title_gp = gpar(fontsize = 10, fontface = "bold"),
        legend_height = unit(3, "cm")
    )
)

pdf("scRNA_marker_heatmap.pdf", width = 10, height = 12)
draw(ht, heatmap_legend_side = "right")
dev.off()
```

## 4. Multi-Omics Integration Heatmap

**Scenario**: Integrate gene expression, DNA methylation, and copy number data.

```r
# Three data matrices (same genes/samples)
set.seed(123)
n_genes <- 50
n_samples <- 20

expr_mat <- matrix(rnorm(n_genes * n_samples), n_genes, n_samples)
meth_mat <- matrix(runif(n_genes * n_samples), n_genes, n_samples)
cnv_mat <- matrix(sample(c(-1, 0, 1), n_genes * n_samples, 
                         replace = TRUE, prob = c(0.1, 0.8, 0.1)), 
                  n_genes, n_samples)

rownames(expr_mat) <- rownames(meth_mat) <- rownames(cnv_mat) <- paste0("Gene", 1:n_genes)
colnames(expr_mat) <- colnames(meth_mat) <- colnames(cnv_mat) <- paste0("Sample", 1:n_samples)

# Sample metadata
sample_groups <- c(rep("Primary", 10), rep("Metastasis", 10))

col_anno <- HeatmapAnnotation(
    Type = sample_groups,
    col = list(Type = c("Primary" = "#00A087", "Metastasis" = "#DC0000")),
    annotation_name_side = "left"
)

# Expression heatmap
ht_expr <- Heatmap(
    t(scale(t(expr_mat))),
    name = "Expression\nZ-score",
    col = colorRamp2(c(-2, 0, 2), c("green", "black", "red")),
    show_row_names = TRUE,
    show_column_names = FALSE,
    row_names_gp = gpar(fontsize = 7),
    cluster_rows = TRUE,
    cluster_columns = TRUE,
    show_column_dend = TRUE,
    column_dend_height = unit(1.5, "cm"),
    top_annotation = col_anno,
    width = unit(6, "cm"),
    column_title = "Expression",
    column_title_gp = gpar(fontsize = 11)
)

# Methylation heatmap
ht_meth <- Heatmap(
    meth_mat,
    name = "Methylation\nBeta",
    col = colorRamp2(c(0, 0.5, 1), c("blue", "white", "orange")),
    show_row_names = FALSE,
    show_column_names = FALSE,
    cluster_rows = FALSE,  # Match expr clustering
    cluster_columns = FALSE,
    width = unit(6, "cm"),
    column_title = "Methylation",
    column_title_gp = gpar(fontsize = 11)
)

# CNV heatmap
ht_cnv <- Heatmap(
    cnv_mat,
    name = "CNV",
    col = c("-1" = "blue", "0" = "white", "1" = "red"),
    show_row_names = FALSE,
    show_column_names = FALSE,
    cluster_rows = FALSE,
    cluster_columns = FALSE,
    width = unit(3, "cm"),
    column_title = "CNV",
    column_title_gp = gpar(fontsize = 11)
)

# Combine
ht_list <- ht_expr + ht_meth + ht_cnv

pdf("multi_omics_heatmap.pdf", width = 16, height = 12)
draw(ht_list, 
     main_heatmap = "Expression\nZ-score",
     heatmap_legend_side = "right")
dev.off()
```

## 5. Clinical Data with Survival Heatmap

**Scenario**: Heatmap with comprehensive clinical annotations.

```r
# Expression data
expr_mat <- matrix(rnorm(100 * 50), 100, 50)
rownames(expr_mat) <- paste0("Gene", 1:100)
colnames(expr_mat) <- paste0("Patient", 1:50)

# Clinical data
clinical <- data.frame(
    patient = colnames(expr_mat),
    age = sample(30:80, 50, replace = TRUE),
    gender = sample(c("M", "F"), 50, replace = TRUE),
    stage = sample(c("I", "II", "III", "IV"), 50, replace = TRUE),
    grade = sample(c("G1", "G2", "G3"), 50, replace = TRUE),
    survival_months = sample(1:120, 50, replace = TRUE),
    status = sample(c("Alive", "Deceased"), 50, replace = TRUE),
    response = sample(c("CR", "PR", "SD", "PD"), 50, replace = TRUE)
)

# Top annotation: Categorical variables
top_anno <- HeatmapAnnotation(
    Gender = clinical$gender,
    Stage = clinical$stage,
    Grade = clinical$grade,
    Response = clinical$response,
    Status = clinical$status,
    
    col = list(
        Gender = c("M" = "steelblue", "F" = "pink"),
        Stage = c("I" = "#FEE5D9", "II" = "#FCAE91", "III" = "#FB6A4A", "IV" = "#CB181D"),
        Grade = c("G1" = "#FFFFCC", "G2" = "#A1DAB4", "G3" = "#41B6C4"),
        Response = c("CR" = "darkgreen", "PR" = "lightgreen", "SD" = "yellow", "PD" = "red"),
        Status = c("Alive" = "green", "Deceased" = "black")
    ),
    annotation_name_side = "left",
    annotation_name_gp = gpar(fontsize = 9),
    gap = unit(1, "mm")
)

# Bottom annotation: Continuous variables
bottom_anno <- HeatmapAnnotation(
    Age = anno_barplot(
        clinical$age,
        gp = gpar(fill = "gray70"),
        height = unit(2, "cm")
    ),
    Survival = anno_points(
        clinical$survival_months,
        ylim = c(0, 120),
        pch = ifelse(clinical$status == "Alive", 16, 4),
        size = unit(2, "mm"),
        gp = gpar(col = ifelse(clinical$status == "Alive", "blue", "red"))
    ),
    annotation_name_side = "left",
    annotation_name_gp = gpar(fontsize = 9)
)

# Create heatmap
ht <- Heatmap(
    t(scale(t(expr_mat))),
    name = "Z-score",
    col = colorRamp2(c(-2, 0, 2), c("#313695", "white", "#A50026")),
    
    # Clustering
    cluster_rows = TRUE,
    cluster_columns = TRUE,
    clustering_distance_columns = "pearson",
    clustering_method_columns = "ward.D2",
    
    # Display
    show_row_names = FALSE,
    show_column_names = TRUE,
    column_names_gp = gpar(fontsize = 7),
    column_names_rot = 90,
    
    # Annotations
    top_annotation = top_anno,
    bottom_annotation = bottom_anno,
    
    # Titles
    column_title = "Patients",
    column_title_gp = gpar(fontsize = 14, fontface = "bold"),
    
    # Size
    width = unit(18, "cm"),
    height = unit(15, "cm")
)

pdf("clinical_heatmap.pdf", width = 20, height = 18)
draw(ht, heatmap_legend_side = "right", annotation_legend_side = "bottom")
dev.off()
```

## 6. Time-Course Expression Heatmap

**Scenario**: Gene expression across multiple time points.

```r
# Expression matrix: genes x timepoints
time_points <- paste0("T", c(0, 6, 12, 24, 48, 72))
n_genes <- 100

expr_mat <- matrix(rnorm(n_genes * length(time_points)), 
                   nrow = n_genes,
                   ncol = length(time_points))
rownames(expr_mat) <- paste0("Gene", 1:n_genes)
colnames(expr_mat) <- time_points

# Gene clusters (response patterns)
gene_patterns <- sample(c("Early", "Late", "Sustained"), n_genes, replace = TRUE)

# Row annotation
row_anno <- rowAnnotation(
    Pattern = gene_patterns,
    col = list(Pattern = c("Early" = "#E64B35", "Late" = "#4DBBD5", "Sustained" = "#00A087"))
)

# Top annotation: Time course plot
top_anno <- HeatmapAnnotation(
    TimeCourse = anno_lines(
        t(expr_mat),
        gp = gpar(col = 1:n_genes, lwd = 0.5),
        height = unit(3, "cm")
    ),
    annotation_name_side = "left"
)

# Heatmap
ht <- Heatmap(
    t(scale(t(expr_mat))),
    name = "Z-score",
    col = colorRamp2(c(-2, 0, 2), c("blue", "white", "red")),
    
    # Clustering
    cluster_rows = TRUE,
    cluster_columns = FALSE,  # Keep time order
    clustering_distance_rows = "pearson",
    
    # Split by pattern
    row_split = gene_patterns,
    row_title = "%s response",
    row_gap = unit(2, "mm"),
    
    # Display
    show_row_names = FALSE,
    show_column_names = TRUE,
    column_names_gp = gpar(fontsize = 12),
    
    # Annotations
    top_annotation = top_anno,
    right_annotation = row_anno,
    
    # Titles
    column_title = "Time (hours)",
    column_title_gp = gpar(fontsize = 14, fontface = "bold")
)

pdf("timecourse_heatmap.pdf", width = 10, height = 14)
draw(ht)
dev.off()
```

## 7. Correlation Network Heatmap

**Scenario**: Visualize gene-gene correlation with network properties.

```r
# Calculate correlation
cor_mat <- cor(t(expr_mat[1:50,]), method = "spearman")

# Network properties (example: degree, betweenness)
# Normally calculated from igraph
library(igraph)

# Create network (threshold correlations)
adj_mat <- ifelse(abs(cor_mat) > 0.3, 1, 0)
diag(adj_mat) <- 0

g <- graph_from_adjacency_matrix(adj_mat, mode = "undirected")

# Calculate properties
node_degree <- degree(g)
node_between <- betweenness(g)

# Row annotations
row_anno <- rowAnnotation(
    Degree = anno_barplot(
        node_degree,
        gp = gpar(fill = "steelblue"),
        width = unit(2, "cm")
    ),
    Betweenness = anno_points(
        node_between,
        pch = 16,
        size = unit(2, "mm"),
        gp = gpar(col = "red")
    ),
    annotation_name_side = "top"
)

# Heatmap
ht <- Heatmap(
    cor_mat,
    name = "Correlation",
    col = colorRamp2(c(-1, 0, 1), c("#4575B4", "white", "#D73027")),
    
    # Clustering
    cluster_rows = TRUE,
    cluster_columns = TRUE,
    clustering_distance_rows = "euclidean",
    clustering_method_rows = "average",
    
    # Display
    show_row_names = TRUE,
    show_column_names = TRUE,
    row_names_gp = gpar(fontsize = 7),
    column_names_gp = gpar(fontsize = 7),
    column_names_rot = 45,
    
    # Cell borders
    rect_gp = gpar(col = "white", lwd = 0.5),
    
    # Annotations
    right_annotation = row_anno,
    
    # Make square
    width = ncol(cor_mat) * unit(5, "mm"),
    height = nrow(cor_mat) * unit(5, "mm")
)

pdf("correlation_network_heatmap.pdf", width = 12, height = 12)
draw(ht, heatmap_legend_side = "left")
dev.off()
```

## 8. TCGA-Style OncoPrint

**Scenario**: Comprehensive genomic alteration landscape.

```r
# Alteration matrix
genes <- c("TP53", "KRAS", "EGFR", "PTEN", "PIK3CA", "BRAF", "NRAS", "APC", "BRCA1", "BRCA2")
samples <- paste0("Sample", 1:100)

mat <- matrix("", nrow = length(genes), ncol = length(samples))
rownames(mat) <- genes
colnames(mat) <- samples

# Simulate alterations
for(i in 1:nrow(mat)) {
    for(j in 1:ncol(mat)) {
        x <- runif(1)
        gene_prob <- runif(1, 0.05, 0.3)  # Gene-specific alteration frequency
        
        if(x < gene_prob * 0.5) mat[i,j] <- "MUT"
        else if(x < gene_prob * 0.7) mat[i,j] <- "AMP"
        else if(x < gene_prob * 0.85) mat[i,j] <- "HOMDEL"
        else if(x < gene_prob) mat[i,j] <- "MUT;AMP"
    }
}

# Sample annotations
sample_subtypes <- sample(c("BRCA", "LUAD", "COAD"), length(samples), replace = TRUE)
sample_gender <- sample(c("Male", "Female"), length(samples), replace = TRUE)

col_anno <- HeatmapAnnotation(
    Subtype = sample_subtypes,
    Gender = sample_gender,
    col = list(
        Subtype = c("BRCA" = "#E64B35", "LUAD" = "#4DBBD5", "COAD" = "#00A087"),
        Gender = c("Male" = "steelblue", "Female" = "pink")
    ),
    annotation_name_side = "left"
)

# Alteration colors and functions
col <- c("MUT" = "#008000", "AMP" = "#FF0000", "HOMDEL" = "#0000FF")

alter_fun <- list(
    background = function(x, y, w, h) {
        grid.rect(x, y, w, h, gp = gpar(fill = "#EEEEEE", col = NA))
    },
    MUT = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.9, gp = gpar(fill = col["MUT"], col = NA))
    },
    AMP = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.33, gp = gpar(fill = col["AMP"], col = NA))
    },
    HOMDEL = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.33, gp = gpar(fill = col["HOMDEL"], col = NA))
    }
)

# Create OncoPrint
oncoPrint(mat,
    alter_fun = alter_fun,
    col = col,
    
    # Annotations
    top_annotation = col_anno,
    
    # Side barplots
    right_annotation = rowAnnotation(
        rbar = anno_oncoprint_barplot()
    ),
    bottom_annotation = HeatmapAnnotation(
        cbar = anno_oncoprint_barplot()
    ),
    
    # Ordering
    column_order = order(sample_subtypes),
    row_order = order(rowSums(mat != ""), decreasing = TRUE),
    
    # Display
    show_column_names = FALSE,
    show_row_names = TRUE,
    row_names_side = "left",
    row_names_gp = gpar(fontsize = 11, fontface = "bold.italic"),
    
    # Titles
    column_title = "TCGA Pan-Cancer Alterations",
    column_title_gp = gpar(fontsize = 14, fontface = "bold"),
    
    # Legend
    heatmap_legend_param = list(
        title = "Alterations",
        at = c("MUT", "AMP", "HOMDEL"),
        labels = c("Mutation", "Amplification", "Homozygous Deletion"),
        nrow = 1
    )
)
```

## See Also

- [Basic Usage Reference](file:///e:/skills/complexheatmap/references/basic_usage.md)
- [Annotation System](file:///e:/skills/complexheatmap/references/annotations.md)
- [Advanced Features](file:///e:/skills/complexheatmap/references/advanced_features.md)
