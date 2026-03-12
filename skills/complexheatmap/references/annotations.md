# ComplexHeatmap Annotation System Reference

## Overview

The annotation system in ComplexHeatmap is one of its most powerful features, allowing you to add rich contextual information to heatmap margins. Annotations can be simple color bars or complex graphics like barplots, boxplots, and custom drawings.

## HeatmapAnnotation vs rowAnnotation

### HeatmapAnnotation

For **column annotations** (top or bottom of heatmap):

```r
col_anno <- HeatmapAnnotation(
    Variable1 = vector1,
    Variable2 = vector2,
    ...
)

Heatmap(mat, top_annotation = col_anno)
```

### rowAnnotation

For **row annotations** (left or right of heatmap):

```r
row_anno <- rowAnnotation(
    Variable1 = vector1,
    Variable2 = vector2,
    ...
)

Heatmap(mat, right_annotation = row_anno)
```

**Key difference**: Syntax is almost identical; the function name determines orientation.

## Simple Annotations

Simple annotations display colored blocks representing categorical or continuous variables.

### Categorical Variables

```r
# Define categorical variable
groups <- c(rep("Control", 5), rep("Treatment", 5))

# Create annotation with color mapping
anno <- HeatmapAnnotation(
    Group = groups,
    col = list(Group = c("Control" = "blue", "Treatment" = "red"))
)

Heatmap(mat, top_annotation = anno)
```

### Continuous Variables

```r
# Continuous variable (automatically mapped to color gradient)
scores <- runif(10, 0, 100)

anno <- HeatmapAnnotation(
    Score = scores,
    col = list(Score = colorRamp2(c(0, 50, 100), c("white", "yellow", "red")))
)
```

### Multiple Simple Annotations

```r
# Multiple annotation tracks
anno <- HeatmapAnnotation(
    Group = c(rep("A", 5), rep("B", 5)),
    Type = sample(c("X", "Y"), 10, replace = TRUE),
    Score = runif(10),
    
    # Color mappings
    col = list(
        Group = c("A" = "#E64B35", "B" = "#4DBBD5"),
        Type = c("X" = "purple", "Y" = "orange"),
        Score = colorRamp2(c(0, 0.5, 1), c("blue", "white", "red"))
    ),
    
    # Customize annotation names
    annotation_name_side = "left",
    annotation_name_gp = gpar(fontsize = 10)
)
```

## Complex Annotations

Complex annotations use specialized `anno_*()` functions to create various plot types.

### anno_points()

Display points (scatter plot).

**Parameters**:
- `x`: Numeric vector of values
- `ylim`: Y-axis limits
- `pch`: Point character
- `size`: Point size
- `gp`: Graphics parameters

**Example**:
```r
HeatmapAnnotation(
    Score = anno_points(
        runif(10, 0, 1),
        ylim = c(0, 1),
        pch = 16,
        size = unit(2, "mm"),
        gp = gpar(col = "red")
    )
)
```

**Advanced example with conditional coloring**:
```r
values <- rnorm(10)
colors <- ifelse(values > 0, "red", "blue")

HeatmapAnnotation(
    Value = anno_points(
        values,
        ylim = range(values),
        pch = 16,
        size = unit(3, "mm"),
        gp = gpar(col = colors)
    )
)
```

### anno_barplot()

Display bar charts.

**Parameters**:
- `x`: Numeric vector or matrix
- `baseline`: Baseline value (default: 0)
- `ylim`: Y-axis limits
- `bar_width`: Relative width of bars
- `gp`: Graphics parameters
- `border`: Bar borders

**Example: Simple barplot**:
```r
HeatmapAnnotation(
    Count = anno_barplot(
        sample(1:100, 10),
        gp = gpar(fill = "steelblue"),
        border = TRUE
    )
)
```

**Example: Stacked barplot (matrix input)**:
```r
# Matrix where each column = one bar, rows = stacked segments
bar_mat <- matrix(sample(1:10, 30, replace = TRUE), nrow = 3, ncol = 10)
rownames(bar_mat) <- c("Category1", "Category2", "Category3")

HeatmapAnnotation(
    Composition = anno_barplot(
        bar_mat,
        gp = gpar(fill = c("red", "green", "blue")),
        border = TRUE,
        height = unit(3, "cm")
    )
)
```

**Example: Positive and negative bars**:
```r
values <- rnorm(10, mean = 0, sd = 5)

HeatmapAnnotation(
    Diff = anno_barplot(
        values,
        baseline = 0,
        gp = gpar(fill = ifelse(values > 0, "red", "blue")),
        ylim = range(values)
    )
)
```

### anno_boxplot()

Display box plots (requires matrix input).

**Parameters**:
- `x`: Matrix (rows = observations, columns = groups)
- `outline`: Show outliers
- `gp`: Graphics parameters

**Example**:
```r
# Each column represents a group's distribution
box_mat <- matrix(rnorm(100), nrow = 10, ncol = 10)

HeatmapAnnotation(
    Distribution = anno_boxplot(
        box_mat,
        outline = TRUE,
        gp = gpar(fill = "lightblue"),
        height = unit(3, "cm")
    )
)
```

### anno_lines()

Display line plots.

**Parameters**:
- `x`: Numeric vector or matrix
- `ylim`: Y-axis limits
- `gp`: Graphics parameters
- `smooth`: Whether to smooth lines

**Example: Single line**:
```r
HeatmapAnnotation(
    Trend = anno_lines(
        sin(seq(0, 2*pi, length.out = 10)),
        ylim = c(-1, 1),
        gp = gpar(col = "red", lwd = 2)
    )
)
```

**Example: Multiple lines (matrix input)**:
```r
line_mat <- matrix(rnorm(30), nrow = 3, ncol = 10)

HeatmapAnnotation(
    Profiles = anno_lines(
        line_mat,
        gp = gpar(col = c("red", "blue", "green"), lwd = 2),
        height = unit(3, "cm")
    )
)
```

### anno_text()

Display text labels.

**Parameters**:
- `x`: Character vector
- `which`: "column" or "row"
- `location`: Position (0 = bottom/left, 1 = top/right)
- `just`: Justification
- `gp`: Text graphics parameters
- `rot`: Rotation angle

**Example**:
```r
HeatmapAnnotation(
    Label = anno_text(
        paste0("Sample", 1:10),
        location = 0.5,
        just = "center",
        gp = gpar(fontsize = 10, col = "black"),
        rot = 0
    )
)
```

**Example: Rotated labels for row annotation**:
```r
rowAnnotation(
    GeneName = anno_text(
        paste0("Gene", 1:nrow(mat)),
        location = unit(2, "mm"),
        just = "left",
        gp = gpar(fontsize = 8),
        rot = 0
    )
)
```

### anno_mark()

Mark specific columns/rows with labels and connectors.

**Parameters**:
- `at`: Indices of columns/rows to mark
- `labels`: Text labels
- `side`: "top", "bottom", "left", or "right"
- `labels_gp`: Label graphics parameters
- `link_width`: Width of connecting lines

**Example**:
```r
# Mark specific samples
HeatmapAnnotation(
    Mark = anno_mark(
        at = c(2, 5, 8),
        labels = c("Outlier1", "Control", "Outlier2"),
        labels_gp = gpar(fontsize = 10, col = "red")
    )
)
```

**Example for row annotation**:
```r
# Mark important genes
rowAnnotation(
    Important = anno_mark(
        at = c(5, 15, 25),
        labels = c("TP53", "BRCA1", "MYC"),
        labels_gp = gpar(fontsize = 12, fontface = "bold")
    )
)
```

### anno_link()

Connect annotations to specific positions.

**Parameters**:
- `at`: Position to link to
- `labels`: Labels
- `side`: Side to place label
- `link_width`: Width of link lines

**Example**:
```r
HeatmapAnnotation(
    Links = anno_link(
        at = c(1, 5, 9),
        labels = c("Start", "Middle", "End"),
        link_width = unit(5, "mm"),
        labels_gp = gpar(fontsize = 9)
    )
)
```

### anno_density()

Display density curves.

**Parameters**:
- `x`: Numeric vector or matrix
- `type`: "lines" or "violin"
- `gp`: Graphics parameters

**Example**:
```r
# Density for each column
density_mat <- matrix(rnorm(100), nrow = 10, ncol = 10)

HeatmapAnnotation(
    Density = anno_density(
        density_mat,
        type = "violin",
        gp = gpar(fill = "lightblue"),
        height = unit(2, "cm")
    )
)
```

### anno_histogram()

Display histograms.

**Parameters**:
- `x`: Numeric vector or matrix
- `n_breaks`: Number of bins
- `gp`: Graphics parameters

**Example**:
```r
HeatmapAnnotation(
    Histogram = anno_histogram(
        matrix(rnorm(100), nrow = 10, ncol = 10),
        n_breaks = 20,
        gp = gpar(fill = "gray"),
        height = unit(3, "cm")
    )
)
```

### anno_simple()

Explicitly create simple annotations (colored blocks).

**Parameters**:
- `x`: Vector of values
- `col`: Color mapping
- `pch`: Point character (for continuous values)
- `pt_size`: Point size
- `height`/`width`: Annotation size

**Example**:
```r
HeatmapAnnotation(
    Category = anno_simple(
        c(rep("A", 5), rep("B", 5)),
        col = c("A" = "red", "B" = "blue"),
        height = unit(5, "mm")
    )
)
```

## Custom Annotation Functions

Create completely custom annotations using raw grid graphics.

**Template**:
```r
my_custom_anno <- function(index) {
    # index: vector of column/row indices
    n <- length(index)
    
    # Define drawing function
    anno_fun <- function(index, k = NULL, N = NULL) {
        # k: current slice index (if heatmap is split)
        # N: total number of slices
        
        # Use grid graphics to draw
        pushViewport(viewport())
        
        # Your custom drawing code here
        # Example: draw random circles
        for(i in seq_along(index)) {
            grid.circle(
                x = (i - 0.5) / n,
                y = 0.5,
                r = 0.1,
                gp = gpar(fill = sample(c("red", "blue"), 1))
            )
        }
        
        popViewport()
    }
    
    # Return AnnotationFunction object
    AnnotationFunction(
        fun = anno_fun,
        var_import = list(n = n),  # Variables to import into function
        n = n,  # Number of observations
        height = unit(1, "cm"),  # Size
        which = "column"  # "column" or "row"
    )
}

# Use custom annotation
HeatmapAnnotation(
    Custom = my_custom_anno(1:10)
)
```

**Advanced example: Timeline annotation**:
```r
anno_timeline <- function(dates, events) {
    n <- length(dates)
    
    anno_fun <- function(index, k = NULL, N = NULL) {
        pushViewport(viewport())
        
        # Draw timeline
        grid.segments(0, 0.5, 1, 0.5, gp = gpar(lwd = 2))
        
        # Draw event markers
        for(i in seq_along(index)) {
            x <- (i - 0.5) / n
            grid.circle(x, 0.5, r = unit(2, "mm"), gp = gpar(fill = "red"))
            grid.text(events[i], x, 0.2, rot = 45, 
                     gp = gpar(fontsize = 8))
        }
        
        popViewport()
    }
    
    AnnotationFunction(
        fun = anno_fun,
        var_import = list(n = n, events = events),
        n = n,
        height = unit(2, "cm"),
        which = "column"
    )
}

# Usage
HeatmapAnnotation(
    Timeline = anno_timeline(
        dates = seq.Date(as.Date("2020-01-01"), by = "month", length.out = 10),
        events = paste0("Event", 1:10)
    )
)
```

## Annotation Customization

### Size Control

```r
HeatmapAnnotation(
    Anno1 = anno_points(runif(10)),
    Anno2 = anno_barplot(sample(1:10, 10)),
    
    # Individual heights
    annotation_height = unit(c(1, 2), "cm"),
    
    # Or set globally
    height = unit(3, "cm")  # Total height
)
```

### Annotation Names

```r
HeatmapAnnotation(
    Group = groups,
    Score = scores,
    
    # Name positioning
    annotation_name_side = "left",  # or "right"
    
    # Name styling
    annotation_name_gp = gpar(fontsize = 10, fontface = "bold", col = "blue"),
    
    # Name rotation
    annotation_name_rot = 45,
    
    # Hide specific names
    show_annotation_name = c(Group = TRUE, Score = FALSE)
)
```

### Gaps Between Annotations

```r
HeatmapAnnotation(
    Anno1 = groups,
    Anno2 = scores,
    Anno3 = types,
    
    # Gap size
    gap = unit(2, "mm")
)
```

### Border Around Annotations

```r
HeatmapAnnotation(
    Group = groups,
    
    # Add border
    border = TRUE,
    
    # Or customize
    annotation_border = c(Group = TRUE)  # Per-annotation control
)
```

## Annotation Legends

### Simple Annotation Legends

Automatically generated for simple annotations:

```r
HeatmapAnnotation(
    Group = groups,
    col = list(Group = c("A" = "red", "B" = "blue")),
    
    # Legend customization
    annotation_legend_param = list(
        Group = list(
            title = "Sample Group",
            title_gp = gpar(fontsize = 12, fontface = "bold"),
            labels_gp = gpar(fontsize = 10),
            nrow = 1  # Horizontal legend
        )
    )
)
```

### Complex Annotation Legends

Use `anno_legend_param` within complex annotation functions:

```r
HeatmapAnnotation(
    Barplot = anno_barplot(
        sample(1:10, 10),
        height = unit(2, "cm"),
        
        # Add custom legend
        annotation_legend_param = list(
            title = "Count",
            at = c(0, 5, 10),
            labels = c("Low", "Medium", "High")
        )
    )
)
```

### Hide Annotation Legends

```r
HeatmapAnnotation(
    Group = groups,
    Score = scores,
    
    # Hide all legends
    show_legend = FALSE,
    
    # Or hide specific legends
    show_legend = c(Group = TRUE, Score = FALSE)
)
```

## Combining Multiple Annotation Types

```r
# Comprehensive example
anno <- HeatmapAnnotation(
    # Simple categorical
    Group = sample(c("Control", "Treatment"), 10, replace = TRUE),
    
    # Simple continuous
    Age = sample(20:80, 10),
    
    # Points
    Expression = anno_points(
        rnorm(10),
        ylim = c(-3, 3),
        gp = gpar(col = "red", size = unit(3, "mm"))
    ),
    
    # Barplot
    Count = anno_barplot(
        sample(1:100, 10),
        gp = gpar(fill = "steelblue")
    ),
    
    # Text labels
    Label = anno_text(
        paste0("S", 1:10),
        gp = gpar(fontsize = 9)
    ),
    
    # Color mappings for simple annotations
    col = list(
        Group = c("Control" = "#4DBBD5", "Treatment" = "#E64B35"),
        Age = colorRamp2(c(20, 50, 80), c("white", "yellow", "red"))
    ),
    
    # Overall customization
    annotation_name_side = "left",
    annotation_name_gp = gpar(fontsize = 10),
    gap = unit(2, "mm"),
    height = unit(6, "cm")
)

Heatmap(mat, top_annotation = anno)
```

## Row Annotations

Everything works the same for row annotations, just use `rowAnnotation()`:

```r
row_anno <- rowAnnotation(
    # Simple
    Pathway = rep(c("P1", "P2", "P3"), each = ceiling(nrow(mat)/3))[1:nrow(mat)],
    
    # Barplot (horizontal for rows)
    Score = anno_barplot(
        runif(nrow(mat)),
        width = unit(3, "cm")  # Note: width instead of height
    ),
    
    # Text
    GeneName = anno_text(
        rownames(mat),
        location = unit(2, "mm"),
        just = "left"
    ),
    
    col = list(Pathway = c("P1" = "red", "P2" = "blue", "P3" = "green")),
    annotation_name_side = "top",  # For row annotations
    width = unit(5, "cm")
)

Heatmap(mat, right_annotation = row_anno)
```

## Practical Examples

### Example 1: Sample Metadata Annotation

```r
# Sample metadata
sample_data <- data.frame(
    sample = colnames(mat),
    group = c(rep("Control", 5), rep("Treatment", 5)),
    batch = rep(c("Batch1", "Batch2"), each = 5),
    age = sample(20:80, 10),
    response = sample(c("R", "NR"), 10, replace = TRUE)
)

# Create comprehensive annotation
col_anno <- HeatmapAnnotation(
    df = sample_data[, c("group", "batch", "response")],
    
    Age = anno_barplot(
        sample_data$age,
        gp = gpar(fill = "gray"),
        height = unit(2, "cm")
    ),
    
    col = list(
        group = c("Control" = "blue", "Treatment" = "red"),
        batch = c("Batch1" = "green", "Batch2" = "orange"),
        response = c("R" = "gold", "NR" = "gray")
    ),
    
    annotation_name_side = "left",
    gap = unit(1, "mm")
)

Heatmap(mat, top_annotation = col_anno)
```

### Example 2: Gene Pathway Annotation

```r
# Gene to pathway mapping
gene_pathways <- rep(c("Metabolism", "Signaling", "Transcription"), 
                     each = ceiling(nrow(mat)/3))[1:nrow(mat)]

# Mean expression per gene
gene_means <- rowMeans(mat)

row_anno <- rowAnnotation(
    Pathway = gene_pathways,
    
    MeanExpr = anno_barplot(
        gene_means,
        gp = gpar(fill = ifelse(gene_means > median(gene_means), 
                                "red", "blue")),
        width = unit(3, "cm")
    ),
    
    col = list(
        Pathway = c("Metabolism" = "#F8766D", 
                   "Signaling" = "#00BA38",
                   "Transcription" = "#619CFF")
    ),
    
    annotation_name_side = "top",
    width = unit(5, "cm")
)

Heatmap(mat, right_annotation = row_anno)
```

### Example 3: Clinical Data Integration

```r
# Multiple clinical annotations
clinical_anno <- HeatmapAnnotation(
    # Categorical variables
    Diagnosis = sample(c("Type1", "Type2", "Type3"), 20, replace = TRUE),
    Stage = sample(c("I", "II", "III", "IV"), 20, replace = TRUE),
    Gender = sample(c("M", "F"), 20, replace = TRUE),
    
    # Continuous variables as barplots
    TumorSize = anno_barplot(
        runif(20, 1, 10),
        gp = gpar(fill = "darkred"),
        height = unit(1.5, "cm")
    ),
    
    # Survival data as points
    Survival = anno_points(
        runif(20, 0, 120),
        ylim = c(0, 120),
        pch = 16,
        size = unit(2, "mm"),
        gp = gpar(col = "darkgreen")
    ),
    
    col = list(
        Diagnosis = c("Type1" = "#E64B35", "Type2" = "#4DBBD5", "Type3" = "#00A087"),
        Stage = c("I" = "#F8E71C", "II" = "#F5B041", "III" = "#E67E22", "IV" = "#A93226"),
        Gender = c("M" = "steelblue", "F" = "pink")
    ),
    
    annotation_name_side = "left",
    annotation_name_gp = gpar(fontsize = 9),
    gap = unit(1, "mm")
)

Heatmap(mat, top_annotation = clinical_anno)
```

## Tips and Best Practices

1. **Consistent styling**: Use the same font sizes and color schemes across all annotations
2. **Meaningful color palettes**: Choose colors that make biological/clinical sense
3. **Annotation ordering**: Place most important annotations closest to the heatmap
4. **Size balance**: Make sure annotations don't overwhelm the heatmap itself
5. **Legend management**: Hide redundant legends to reduce clutter
6. **Performance**: For large datasets, avoid overly complex annotations (e.g., text on every cell)

## See Also

- [Basic Usage Reference](file:///e:/skills/complexheatmap/references/basic_usage.md)
- [Advanced Features](file:///e:/skills/complexheatmap/references/advanced_features.md)
- [Example Gallery](file:///e:/skills/complexheatmap/references/gallery.md)
