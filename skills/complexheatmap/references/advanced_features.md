# ComplexHeatmap Advanced Features

## Heatmap Splitting

Splitting allows you to divide heatmaps into groups with visual gaps.

### Split by K-means Clustering

```r
# Split rows into 3 groups
Heatmap(mat, row_split = 3, column_split = 2)
```

### Split by Categorical Variable

```r
# Define groups
row_groups <- c(rep("Group A", 10), rep("Group B", 15), rep("Group C", 5))
column_groups <- c(rep("Tumor", 6), rep("Normal", 4))

Heatmap(mat,
    row_split = row_groups,
    column_split = column_groups,
    row_title = "%s",  # Use group name as title
    column_title = "%s"
)
```

### Control Split Behavior

```r
Heatmap(mat,
    row_split = 3,
    cluster_row_slices = FALSE,  # Don't cluster between groups
    row_gap = unit(5, "mm"),     # Gap size
    border = TRUE                # Add borders around splits
)
```

### Split by Multiple Variables

```r
# Split by data frame
split_df <- data.frame(
    Type = c(rep("A", 10), rep("B", 10)),
    Class = rep(c("I", "II"), each = 5, times = 2)
)

Heatmap(mat, row_split = split_df)
```

## Multiple Heatmap Integration

### Horizontal Concatenation

```r
ht1 <- Heatmap(mat1, name = "Expression", width = unit(6, "cm"))
ht2 <- Heatmap(mat2, name = "Methylation", width = unit(4, "cm"))
ht3 <- Heatmap(mat3, name = "CNV", width = unit(2, "cm"))

# Combine with +
ht_list <- ht1 + ht2 + ht3

draw(ht_list)
```

### Vertical Concatenation

```r
ht_list <- ht1 %v% ht2 %v% ht3

draw(ht_list)
```

### Main Heatmap with Auto Adjustment

Designate one heatmap as "main" - others adjust to it:

```r
ht1 <- Heatmap(mat1, name = "Expr", show_row_dend = TRUE)
ht2 <- Heatmap(mat2, name = "Meth", show_row_dend = FALSE)  # Auto-adjusts to ht1
ht3 <- Heatmap(mat3, name = "CNV", show_row_dend = FALSE)

draw(ht1 + ht2 + ht3, 
     main_heatmap = "Expr")  # Explicitly set main
```

### Row Annotations in HeatmapList

```r
row_anno <- rowAnnotation(
    Pathway = pathway_groups,
    col = list(Pathway = pathway_colors)
)

# Add annotation to the list
ht_list <- ht1 + ht2 + ht3 + row_anno

draw(ht_list)
```

### Auto Adjust Annotations

```r
# Annotations adjust to match clustered heatmap
col_anno <- HeatmapAnnotation(
    Group = groups,
    col = list(Group = group_colors)
)

ht1 <- Heatmap(mat1, name = "Expr", top_annotation = col_anno, cluster_columns = TRUE)
ht2 <- Heatmap(mat2, name = "Meth")  # Columns auto-match ht1

draw(ht1 + ht2)
```

## OncoPrint

Visualize genomic alterations across samples.

### Basic OncoPrint

```r
# Alteration matrix (genes x samples)
mat <- matrix("", nrow = 10, ncol = 20)
mat[sample(1:200, 40)] <- "MUT"
mat[sample(1:200, 20)] <- "AMP"
mat[sample(1:200, 15)] <- "DEL"
mat[sample(1:200, 10)] <- "MUT;AMP"  # Multiple alterations

rownames(mat) <- paste0("Gene", 1:10)
colnames(mat) <- paste0("Sample", 1:20)

# Define colors
col <- c("MUT" = "blue", "AMP" = "red", "DEL" = "green")

# Define how to draw alterations
alter_fun <- list(
    background = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.9, 
                  gp = gpar(fill = "#CCCCCC", col = NA))
    },
    MUT = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.9, 
                  gp = gpar(fill = col["MUT"], col = NA))
    },
    AMP = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.4, 
                  gp = gpar(fill = col["AMP"], col = NA))
    },
    DEL = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.4, 
                  gp = gpar(fill = col["DEL"], col = NA))
    }
)

oncoPrint(mat,
    alter_fun = alter_fun,
    col = col,
    column_title = "OncoPrint Example",
    row_names_side = "left"
)
```

### OncoPrint with Annotations

```r
# Sample annotations
sample_type <- sample(c("Primary", "Metastasis"), 20, replace = TRUE)

col_anno <- HeatmapAnnotation(
    Type = sample_type,
    col = list(Type = c("Primary" = "lightblue",  "Metastasis" = "darkblue"))
)

oncoPrint(mat,
    alter_fun = alter_fun,
    col = col,
    top_annotation = col_anno,
    
    # Show alteration frequencies
    right_annotation = rowAnnotation(
        rbar = anno_oncoprint_barplot()
    ),
    
    # Sample ordering
    column_order = order(sample_type)
)
```

### Custom Alteration Types

```r
# Define more alteration types
col <- c("MUT" = "#3C5488", "AMP" = "#E64B35", "DEL" = "#00A087", 
         "FUSION" = "#F39B7F", "HOMDEL" = "purple")

alter_fun <- list(
    background = function(x, y, w, h) {
        grid.rect(x, y, w, h, gp = gpar(fill = "gray90", col = NA))
    },
    MUT = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.9, 
                  gp = gpar(fill = col["MUT"], col = NA))
    },
    AMP = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.33, 
                  gp = gpar(fill = col["AMP"], col = NA))
    },
    DEL = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.33, 
                  gp = gpar(fill = col["DEL"], col = NA))
    },
    FUSION = function(x, y, w, h) {
        grid.polygon(
            x = c(x-w*0.4, x, x+w*0.4, x),
            y = c(y, y+h*0.4, y, y-h*0.4),
            gp = gpar(fill = col["FUSION"], col = NA)
        )
    },
    HOMDEL = function(x, y, w, h) {
        grid.rect(x, y, w*0.9, h*0.9, 
                  gp = gpar(fill = col["HOMDEL"], col = NA))
    }
)
```

## UpSet Plot Integration

Visualize combinations of genomic alterations:

```r
library(ComplexHeatmap)

# Create combination matrix
m <- make_comb_mat(mat)

# UpSet plot
UpSet(m)

# With custom parameters
UpSet(m,
    set_order = order(set_size(m)),
    comb_order = order(comb_size(m)),
    top_annotation = upset_top_annotation(m, add_numbers = TRUE),
    right_annotation = upset_right_annotation(m, add_numbers = TRUE)
)
```

## Decorating Heatmaps

Add custom graphics to specific regions of heatmaps.

### Decorate Heatmap Body

```r
ht <- Heatmap(mat, name = "Value")

draw(ht)

# Add custom graphics to heatmap body
decorate_heatmap_body("Value", {
    # Draw a rectangle
    grid.rect(x = 0.2, y = 0.8, width = 0.1, height = 0.1, 
              gp = gpar(fill = "yellow", col = "red", lwd = 3))
    
    # Add text
    grid.text("Important!", x = 0.2, y = 0.8, gp = gpar(fontsize = 12))
})
```

### Decorate Annotations

```r
col_anno <- HeatmapAnnotation(
    Group = groups,
    foo = anno_empty(height = unit(2, "cm"))  # Empty annotation for custom drawing
)

ht <- Heatmap(mat, name = "Value", top_annotation = col_anno)

draw(ht)

# Draw custom graphics in empty annotation
decorate_annotation("foo", {
    # Custom plot
    x <- seq(0, 1, length.out = ncol(mat))
    y <- runif(ncol(mat), 0, 1)
    grid.lines(x, y, gp = gpar(col = "red", lwd = 2))
    grid.points(x, y, pch = 16, size = unit(2, "mm"))
})
```

### Decorate Dendrograms

```r
ht <- Heatmap(mat, name = "Value", cluster_rows = TRUE)

draw(ht)

decorate_dend("Value", {
    # Highlight specific branches
    tree <- attr(column_dend(ht), "hclust")
    # Custom dendrogram decorations
})
```

## Interactive Heatmaps

### Basic Interactive Heatmap

```r
library(InteractiveComplexHeatmap)

ht <- Heatmap(mat, name = "Expression")

# Export to Shiny app
htShiny(ht)
```

### Interactive with Custom UI

```r
# More control over the Shiny app
ui <- HTShinyUI(title = "My Interactive Heatmap")
server <- HTShinyServer(ht, title = "Expression Data")

shinyApp(ui, server)
```

## Heatmap Legends

### Customize Legend Position

```r
ht <- Heatmap(mat, name = "Value")

draw(ht, 
     heatmap_legend_side = "left",      # Left, right, top, bottom
     annotation_legend_side = "bottom"
)
```

### Multiple Legend Columns

```r
draw(ht,
     heatmap_legend_side = "right",
     merge_legend = FALSE,  # Don't merge legends
     legend_grouping = "original"  # Group by original order
)
```

### Manual Legend List

```r
# Create custom legends
lgd1 <- Legend(labels = c("A", "B", "C"),
               legend_gp = gpar(fill = c("red", "blue", "green")),
               title = "Category")

lgd2 <- Legend(col_fun = colorRamp2(c(0, 10), c("white", "red")),
               title = "Score",
               at = c(0, 5, 10))

# Draw with custom legends
draw(ht, annotation_legend_list = list(lgd1, lgd2))
```

## Circular Heatmaps

Convert linear heatmap to circular:

```r
library(circlize)

# Create sectors
circos.par(start.degree = 90, gap.degree = 5)

# Initialize
circos.initialize(factors = colnames(mat), x = 1:ncol(mat))

# Add heatmap track
circos.track(ylim = c(0, nrow(mat)), panel.fun = function(x, y) {
    sector.index <- get.cell.meta.data("sector.index")
    m <- mat[, sector.index]
    
    col_fun <- colorRamp2(c(-2, 0, 2), c("blue", "white", "red"))
    
    for(i in 1:length(m)) {
        circos.rect(i-0.9, 0, i-0.1, 1, 
                   col = col_fun(m[i]), border = NA)
    }
})

circos.clear()
```

## Comparing Dendrograms

Compare clustering from two conditions:

```r
# Two conditions
mat1 <- matrix(rnorm(100), 10)
mat2 <- matrix(rnorm(100), 10)

# Cluster both
dend1 <- as.dendrogram(hclust(dist(mat1)))
dend2 <- as.dendrogram(hclust(dist(mat2)))

# Create heatmaps with dendrograms
ht1 <- Heatmap(mat1, name = "Condition1", 
               cluster_rows = dend1, show_row_dend = TRUE)
ht2 <- Heatmap(mat2, name = "Condition2", 
               cluster_rows = dend2, show_row_dend = TRUE)

# Compare side by side
ht1 + ht2
```

## Advanced Clustering

### Consensus Clustering

```r
library(ConsensusClusterPlus)

# Run consensus clustering
results <- ConsensusClusterPlus(mat,
    maxK = 6,
    reps = 1000,
    pItem = 0.8,
    pFeature = 1,
    clusterAlg = "hc",
    distance = "euclidean"
)

# Extract consensus class
consensus_class <- results[[4]][["consensusClass"]]

# Use in heatmap
Heatmap(mat,
    column_split = consensus_class,
    cluster_column_slices = FALSE
)
```

### Bi-clustering

```r
# Use a bi-clustering algorithm
library(biclust)

bc_result <- biclust(mat, method = BCPlaid())

# Visualize bicluster
Heatmap(mat[bc_result@RowxNumber[,1], bc_result@NumberxCol[1,]],
        name = "Bicluster 1")
```

## Performance Optimization

### Rasterization for Large Heatmaps

```r
# Large matrix  
large_mat <- matrix(rnorm(100000), 1000, 100)

Heatmap(large_mat,
    name = "Expression",
    use_raster = TRUE,
    raster_device = "png",  # Or "CairoPNG" for better quality
    raster_quality = 2,     # Quality multiplier
    raster_device_param = list(width = 3000, height = 3000)
)
```

### Subsetting for Preview

```r
# Preview with subset
subset_idx <- sample(1:nrow(large_mat), 100)

Heatmap(large_mat[subset_idx, ], name = "Preview")

# Then create full heatmap when satisfied
```

## Saving Complex Heatmaps

### Different Formats

```r
ht <- Heatmap(mat, name = "Value")

# PDF (vector, recommended)
pdf("heatmap.pdf", width = 10, height = 12)
draw(ht)
dev.off()

# PNG (raster, high resolution)
png("heatmap.png", width = 3000, height = 3600, res = 300)
draw(ht)
dev.off()

# TIFF (for some journals)
tiff("heatmap.tiff", width = 3000, height = 3600, res = 300, compression = "lzw")
draw(ht)
dev.off()

# SVG (web-friendly vector)
svg("heatmap.svg", width = 10, height = 12)
draw(ht)
dev.off()
```

### Get Heatmap as Raster

```r
# Export to raster object for further processing
library(magick)

# Create temporary file
tmp <- tempfile(fileext = ".png")
png(tmp, width = 2000, height = 2000, res = 200)
draw(ht)
dev.off()

# Read back
img <- image_read(tmp)

# Process with magick
img <- image_annotate(img, "Figure 1", size = 40, gravity = "north")
image_write(img, "final_figure.png")
```

## See Also

- [Basic Usage Reference](file:///e:/skills/complexheatmap/references/basic_usage.md)
- [Annotation System](file:///e:/skills/complexheatmap/references/annotations.md)
- [Example Gallery](file:///e:/skills/complexheatmap/references/gallery.md)
