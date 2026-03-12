# ComplexHeatmap Basic Usage Reference

## Heatmap() Function Complete Parameter Reference

This document provides comprehensive documentation for all parameters of the `Heatmap()` function.

### Function Signature

```r
Heatmap(
    matrix,
    col,
    name,
    # Clustering
    cluster_rows,
    cluster_columns,
    clustering_distance_rows,
    clustering_distance_columns,
    clustering_method_rows,
    clustering_method_columns,
    row_dend_width,
    column_dend_height,
    row_dend_reorder,
    column_dend_reorder,
    row_dend_gp,
    column_dend_gp,
    # Splitting
    row_split,
    column_split,
    row_gap,
    column_gap,
    cluster_row_slices,
    cluster_column_slices,
    # Display
    show_row_names,
    show_column_names,
    row_names_side,
    column_names_side,
    row_names_max_width,
    column_names_max_height,
    row_names_gp,
    column_names_gp,
    column_names_rot,
    row_names_rot,
    # Titles
    column_title,
    column_title_side,
    column_title_gp,
    column_title_rot,
    row_title,
    row_title_side,
    row_title_gp,
    row_title_rot,
    # Dimensions
    width,
    height,
    # Heatmap body
    rect_gp,
    cell_fun,
    layer_fun,
    jitter,
    # Annotations
    top_annotation,
    bottom_annotation,
    left_annotation,
    right_annotation,
    # Legends
    heatmap_legend_param,
    show_heatmap_legend,
    # Advanced
    use_raster,
    raster_device,
    raster_quality,
    raster_device_param,
    post_fun,
    ...
)
```

## Core Parameters

### matrix

**Type**: Numeric matrix, data frame, or DelayedMatrix  
**Required**: YES

The input data matrix to visualize. Rows and columns represent features (e.g., genes) and samples respectively, though this can be reversed.

**Example**:
```r
mat <- matrix(rnorm(100), 10, 10)
rownames(mat) <- paste0("Gene", 1:10)
colnames(mat) <- paste0("Sample", 1:10)
Heatmap(mat)
```

**Data requirements**:
- Must be numeric
- Can contain NA values (displayed as white/gray by default)
- Row and column names highly recommended

---

### col

**Type**: Color mapping function or named vector  
**Default**: Auto-generated from data range

Defines how matrix values map to colors.

**Continuous data** (use `colorRamp2()`):
```r
library(circlize)

# Simple gradient
col_fun <- colorRamp2(c(-2, 0, 2), c("blue", "white", "red"))

# Multi-color gradient
col_fun <- colorRamp2(
    breaks = c(-3, -2, -1, 0, 1, 2, 3),
    colors = c("#313695", "#74ADD1", "#E0F3F8", "white", 
               "#FEE090", "#FDAE61", "#D73027")
)

Heatmap(mat, col = col_fun)
```

**Discrete data** (use named vector):
```r
col_discrete <- c("Type1" = "red", "Type2" = "blue", "Type3" = "green")
Heatmap(discrete_mat, col = col_discrete)
```

**Default behavior**: If not specified, uses a blue-white-red gradient for continuous data.

---

### name

**Type**: Character string  
**Default**: "matrix"

The title displayed on the heatmap legend.

**Example**:
```r
Heatmap(mat, name = "Expression\n(log2 TPM)")
Heatmap(mat, name = "Z-score")
```

**Tips**:
- Use `\n` for multi-line legend titles
- Keep concise but informative
- Include units when applicable

---

## Clustering Parameters

### cluster_rows / cluster_columns

**Type**: Logical or `hclust`/`dendrogram` object  
**Default**: TRUE

Controls whether rows/columns are clustered.

**Options**:
```r
# Default clustering
Heatmap(mat, cluster_rows = TRUE, cluster_columns = TRUE)

# No clustering (keep original order)
Heatmap(mat, cluster_rows = FALSE, cluster_columns = FALSE)

# Custom pre-computed clustering
row_clust <- hclust(dist(mat), method = "ward.D2")
Heatmap(mat, cluster_rows = row_clust)

# Custom dendrogram
row_dend <- as.dendrogram(row_clust)
Heatmap(mat, cluster_rows = row_dend)
```

---

### clustering_distance_rows / clustering_distance_columns

**Type**: Character string or function  
**Default**: "euclidean"

Distance metric for clustering.

**Built-in distance methods**:
- `"euclidean"` - Euclidean distance (default)
- `"maximum"` - Maximum distance
- `"manhattan"` - Manhattan distance
- `"canberra"` - Canberra distance
- `"binary"` - Binary distance
- `"minkowski"` - Minkowski distance
- `"pearson"` - 1 - Pearson correlation
- `"spearman"` - 1 - Spearman correlation
- `"kendall"` - 1 - Kendall correlation

**Example**:
```r
# Correlation-based distance
Heatmap(mat, 
    clustering_distance_rows = "pearson",
    clustering_distance_columns = "spearman"
)
```

**Custom distance function**:
```r
my_dist <- function(m) {
    # Custom distance calculation
    # Must return a 'dist' object
    as.dist(1 - cor(t(m), method = "spearman", use = "pairwise.complete.obs"))
}

Heatmap(mat, clustering_distance_rows = my_dist)
```

---

### clustering_method_rows / clustering_method_columns

**Type**: Character string  
**Default**: "complete"

Hierarchical clustering linkage method.

**Available methods**:
- `"complete"` - Complete linkage (default, compact clusters)
- `"single"` - Single linkage (chaining)
- `"average"` - Average linkage (UPGMA)
- `"ward.D"` - Ward's minimum variance method
- `"ward.D2"` - Ward's method (squared distances)
- `"mcquitty"` - McQuitty's method (WPGMA)
- `"median"` - Median linkage (WPGMC)
- `"centroid"` - Centroid linkage (UPGMC)

**Example**:
```r
Heatmap(mat, 
    clustering_method_rows = "ward.D2",
    clustering_method_columns = "average"
)
```

**Choosing the right method**:
- **Complete**: Most common, produces compact clusters
- **Ward linkages**: Minimizes within-cluster variance, good for gene expression
- **Average**: Balanced approach
- **Single**: Can produce long chains, rarely used

---

### row_dend_width / column_dend_height

**Type**: `unit` object  
**Default**: Automatically calculated

Size of the dendrogram.

**Example**:
```r
library(grid)
Heatmap(mat,
    row_dend_width = unit(3, "cm"),
    column_dend_height = unit(2, "cm")
)
```

---

### row_dend_reorder / column_dend_reorder

**Type**: Logical  
**Default**: TRUE

Whether to reorder dendrogram to minimize distance between adjacent leaves.

**Example**:
```r
# Disable reordering
Heatmap(mat, 
    row_dend_reorder = FALSE,
    column_dend_reorder = FALSE
)
```

---

### row_dend_gp / column_dend_gp

**Type**: `gpar` object  
**Default**: Default graphics parameters

Graphics parameters for dendrograms (color, line width, etc.).

**Example**:
```r
Heatmap(mat,
    row_dend_gp = gpar(col = "red", lwd = 2),
    column_dend_gp = gpar(col = "blue", lwd = 1, lty = 2)
)
```

---

## Splitting Parameters

### row_split / column_split

**Type**: Integer, factor, or data frame  
**Default**: NULL (no splitting)

Split heatmap into slices.

**Split by number of groups** (k-means):
```r
# Split into 3 groups
Heatmap(mat, row_split = 3)
```

**Split by categorical variable**:
```r
# Define groups
row_groups <- c(rep("Group A", 5), rep("Group B", 3), rep("Group C", 2))

Heatmap(mat, row_split = row_groups)
```

**Split by data frame** (multiple variables):
```r
split_df <- data.frame(
    Type = c(rep("A", 5), rep("B", 5)),
    Class = sample(c("I", "II"), 10, replace = TRUE)
)

Heatmap(mat, row_split = split_df)
```

---

### row_gap / column_gap

**Type**: `unit` object  
**Default**: unit(1, "mm")

Size of gaps between splits.

**Example**:
```r
Heatmap(mat,
    row_split = 3,
    row_gap = unit(5, "mm"),
    column_gap = unit(2, "mm"),
    border = TRUE
)
```

---

### cluster_row_slices / cluster_column_slices

**Type**: Logical  
**Default**: TRUE

Whether to cluster the slices themselves.

**Example**:
```r
# Split but don't cluster between groups
Heatmap(mat,
    row_split = row_groups,
    cluster_row_slices = FALSE  # Keep group order as defined
)
```

---

## Display Parameters

### show_row_names / show_column_names

**Type**: Logical  
**Default**: TRUE

Whether to display row/column names.

**Example**:
```r
# Hide row names (e.g., too many genes)
Heatmap(mat, 
    show_row_names = FALSE,
    show_column_names = TRUE
)
```

---

### row_names_side / column_names_side

**Type**: Character ("left"/"right" for rows, "top"/"bottom" for columns)  
**Default**: "right" for rows, "bottom" for columns

Position of row/column names.

**Example**:
```r
Heatmap(mat,
    row_names_side = "left",
    column_names_side = "top"
)
```

---

### row_names_gp / column_names_gp

**Type**: `gpar` object  
**Default**: Default text parameters

Graphics parameters for row/column names.

**Example**:
```r
Heatmap(mat,
    row_names_gp = gpar(fontsize = 8, fontface = "italic", col = "blue"),
    column_names_gp = gpar(fontsize = 10, fontface = "bold")
)
```

---

### column_names_rot / row_names_rot

**Type**: Numeric (degrees)  
**Default**: 0

Rotation angle for names.

**Example**:
```r
Heatmap(mat,
    column_names_rot = 45,  # 45-degree angle
    row_names_rot = 0
)
```

---

### row_names_max_width / column_names_max_height

**Type**: `unit` object  
**Default**: Automatically calculated

Maximum space allocated for names.

**Example**:
```r
Heatmap(mat,
    row_names_max_width = unit(6, "cm"),
    column_names_max_height = unit(3, "cm")
)
```

---

## Title Parameters

### column_title / row_title

**Type**: Character string  
**Default**: NULL

Title for columns/rows.

**Example**:
```r
Heatmap(mat,
    column_title = "Tumor Samples",
    row_title = "Differentially Expressed Genes"
)
```

---

### column_title_side / row_title_side

**Type**: Character ("top"/"bottom" for columns, "left"/"right" for rows)  
**Default**: "top" for columns, "left" for rows

Position of titles.

---

### column_title_gp / row_title_gp

**Type**: `gpar` object  
**Default**: Default text parameters

Graphics parameters for titles.

**Example**:
```r
Heatmap(mat,
    column_title = "Samples",
    column_title_gp = gpar(fontsize = 14, fontface = "bold", col = "red")
)
```

---

### column_title_rot / row_title_rot

**Type**: Numeric (degrees)  
**Default**: 0

Rotation angle for titles.

---

## Dimension Parameters

### width / height

**Type**: `unit` object  
**Default**: Automatically calculated

Total size of the heatmap body.

**Example**:
```r
library(grid)
Heatmap(mat,
    width = unit(10, "cm"),
    height = unit(15, "cm")
)
```

**Note**: This sets the size of the heatmap body only, not including dendrograms, annotations, or names.

---

## Heatmap Body Parameters

### rect_gp

**Type**: `gpar` object  
**Default**: Default rectangle parameters

Graphics parameters for heatmap cells.

**Example**:
```r
# Add white borders to cells
Heatmap(mat,
    rect_gp = gpar(col = "white", lwd = 2)
)
```

---

### cell_fun

**Type**: Function  
**Default**: NULL

Custom function to add graphics to each cell.

**Function signature**: `function(j, i, x, y, width, height, fill)`

- `j`: column index
- `i`: row index
- `x, y`: center coordinates (0-1 viewport)
- `width, height`: cell dimensions
- `fill`: cell color

**Example: Add text to cells**:
```r
Heatmap(mat,
    cell_fun = function(j, i, x, y, width, height, fill) {
        # Add value text
        grid.text(sprintf("%.1f", mat[i, j]), x, y, 
                  gp = gpar(fontsize = 8))
    }
)
```

**Example: Mark significant values**:
```r
Heatmap(mat,
    cell_fun = function(j, i, x, y, width, height, fill) {
        if(abs(mat[i, j]) > 2) {
            grid.text("*", x, y, gp = gpar(fontsize = 16))
        }
    }
)
```

---

### layer_fun

**Type**: Function  
**Default**: NULL

More flexible than `cell_fun`, allows vectorized operations on all cells.

**Function signature**: `function(j, i, x, y, width, height, fill)`

**Example**:
```r
Heatmap(mat,
    layer_fun = function(j, i, x, y, width, height, fill) {
        # Add circles for positive values
        l <- mat[i, j] > 1
        if(any(l)) {
            grid.points(x[l], y[l], pch = 16, size = unit(2, "mm"))
        }
    }
)
```

---

## Annotation Parameters

### top_annotation / bottom_annotation

**Type**: `HeatmapAnnotation` object  
**Default**: NULL

Column annotations (top or bottom of heatmap).

**Example**:
```r
col_anno <- HeatmapAnnotation(
    Group = c(rep("A", 5), rep("B", 5)),
    Score = runif(10),
    col = list(Group = c("A" = "red", "B" = "blue"))
)

Heatmap(mat, top_annotation = col_anno)
```

---

### left_annotation / right_annotation

**Type**: `rowAnnotation` object  
**Default**: NULL

Row annotations (left or right of heatmap).

**Example**:
```r
row_anno <- rowAnnotation(
    Pathway = rep(c("P1", "P2"), each = 5),
    col = list(Pathway = c("P1" = "green", "P2" = "orange"))
)

Heatmap(mat, right_annotation = row_anno)
```

See [`annotations.md`](file:///e:/skills/complexheatmap/references/annotations.md) for detailed annotation documentation.

---

## Legend Parameters

### heatmap_legend_param

**Type**: List  
**Default**: Auto-generated parameters

Customize the heatmap legend appearance.

**Available parameters**:
- `title`: Legend title
- `title_gp`: Title graphics parameters
- `title_position`: "topleft", "topcenter", "leftcenter", etc.
- `labels`: Custom labels
- `labels_gp`: Label graphics parameters
- `legend_direction`: "vertical" or "horizontal"
- `legend_width`: Width of legend
- `legend_height`: Height of legend
- `grid_width`: Width of color grid
- `grid_height`: Height of color grid
- `border`: Border color

**Example**:
```r
Heatmap(mat,
    name = "Expression",
    heatmap_legend_param = list(
        title = "Log2 FC",
        title_gp = gpar(fontsize = 12, fontface = "bold"),
        labels_gp = gpar(fontsize = 10),
        legend_height = unit(5, "cm"),
        legend_width = unit(1.5, "cm"),
        direction = "vertical",
        border = "black"
    )
)
```

---

### show_heatmap_legend

**Type**: Logical  
**Default**: TRUE

Whether to show the heatmap legend.

**Example**:
```r
Heatmap(mat, show_heatmap_legend = FALSE)
```

---

## Advanced Parameters

### use_raster

**Type**: Logical  
**Default**: FALSE

Whether to rasterize the heatmap body (improves performance for large matrices).

**Example**:
```r
# For large heatmaps
Heatmap(large_mat, 
    use_raster = TRUE,
    raster_quality = 2  # Higher = better quality
)
```

**When to use**:
- Matrix has > 10000 cells
- Exporting to PDF and file size is too large
- Rendering is slow

**Trade-off**: Loses vector format benefits (no infinite zoom).

---

### raster_device

**Type**: Character ("png", "jpeg", "tiff", "CairoPNG", "CairoJPEG")  
**Default**: "png"

Graphics device for rasterization.

---

### raster_quality

**Type**: Numeric  
**Default**: 1

Quality factor for rasterization (higher = better quality, larger file size).

---

### post_fun

**Type**: Function  
**Default**: NULL

Function executed after drawing the heatmap, useful for adding custom decorations.

**Function signature**: `function(ht)`

**Example**:
```r
Heatmap(mat,
    post_fun = function(ht) {
        # Add custom text or decorations
        decorate_heatmap_body("matrix", {
            grid.text("Custom Label", x = 0.5, y = 0.95, 
                     gp = gpar(fontsize = 12))
        })
    }
)
```

---

## Data Preparation Tips

### Normalization

**Z-score normalization** (row-wise):
```r
mat_scaled <- t(scale(t(mat)))  # Scale each row independently
```

**Log transformation** (for count data):
```r
mat_log <- log2(mat + 1)  # Add pseudocount to avoid log(0)
```

**Quantile normalization**:
```r
library(preprocessCore)
mat_quantile <- normalize.quantiles(as.matrix(mat))
rownames(mat_quantile) <- rownames(mat)
colnames(mat_quantile) <- colnames(mat)
```

### Filtering

**Remove low-variance rows**:
```r
row_vars <- apply(mat, 1, var)
mat_filtered <- mat[row_vars > quantile(row_vars, 0.5), ]
```

**Select top N variable genes**:
```r
top_genes <- head(order(apply(mat, 1, var), decreasing = TRUE), 100)
mat_top <- mat[top_genes, ]
```

**Remove rows with too many NAs**:
```r
max_na <- 0.2  # Allow 20% NAs
na_prop <- rowSums(is.na(mat)) / ncol(mat)
mat_clean <- mat[na_prop <= max_na, ]
```

---

## Common Parameter Combinations

### Publication-quality gene expression heatmap

```r
Heatmap(
    mat_scaled,
    name = "Z-score",
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
    
    # Display
    show_row_names = FALSE,
    show_column_names = TRUE,
    column_names_gp = gpar(fontsize = 10),
    column_names_rot = 45,
    
    # Titles
    column_title = "Samples",
    column_title_gp = gpar(fontsize = 14, fontface = "bold"),
    
    # Size
    width = unit(10, "cm"),
    height = unit(15, "cm"),
    
    # Legend
    heatmap_legend_param = list(
        title_gp = gpar(fontsize = 11, fontface = "bold"),
        labels_gp = gpar(fontsize = 9),
        legend_height = unit(4, "cm")
    )
)
```

### Correlation matrix heatmap

```r
Heatmap(
    cor_mat,
    name = "Correlation",
    col = colorRamp2(c(-1, 0, 1), c("blue", "white", "red")),
    
    # Symmetric clustering
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
    
    # Square cells
    width = ncol(cor_mat) * unit(8, "mm"),
    height = nrow(cor_mat) * unit(8, "mm")
)
```

---

## See Also

- [Annotation System Reference](file:///e:/skills/complexheatmap/references/annotations.md)
- [Advanced Features](file:///e:/skills/complexheatmap/references/advanced_features.md)
- [Example Gallery](file:///e:/skills/complexheatmap/references/gallery.md)
