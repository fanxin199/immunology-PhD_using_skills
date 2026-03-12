---
name: pub-grade-barchart
description: Create publication-quality optimized bar charts for bioinformatics using R (ggpubr/ggrepel) and Python (scienceplots/adjustText).
---

# Publication-Grade Bar Chart Generator

This skill guides the AI to generate high-quality, publication-ready bar charts for bioinformatics and scientific research. It specifically addresses common issues like label overlapping, cluttered legends, and non-standard styling.

## 1. Core Principles

-   **No Overlapping**: ALWAYS use collision-avoidance libraries (`ggrepel` for R, `adjustText` for Python).
-   **Journal Standards**: Adhere to Nature/Science/IEEE style guides (minimalist, clean, high visibility).
-   **Bioinformatics Friendly**: Optimize for long gene names, p-value annotations, and complex groupings.

## 2. R Implementation (Preferred)

Use **R** with `ggplot2` ecosystem as the primary choice for complex statistical bar charts.

### Required Libraries
```r
library(ggplot2)
library(ggpubr)   # For publication themes and easy customization
library(ggrepel)  # CRITICAL: For non-overlapping labels
library(ggsci)    # For journal specific color palettes (e.g., scale_fill_npg())
library(ggprism)  # Optional: For GraphPad Prism style axes
```

### Best Practices Checklist
1.  **Theme**: Use `theme_pubr()` from `ggpubr` as the base.
2.  **Labels**: 
    -   NEVER use `geom_text` directly for dense data.
    -   ALWAYS use `geom_text_repel()` or `geom_label_repel()`.
    -   Use `position = position_dodge()` inside the repel geom for grouped bars.
3.  **Colors**: Use `scale_fill_npg()` (Nature), `scale_fill_aaas()` (Science), or `scale_fill_lancet()`.
4.  **Layout**:
    -   Remove default grid lines unless necessary for reading values.
    -   Ensure `expand` in scale is set to `expansion(mult = c(0, 0.1))` for y-axis to reduce whitespace below bars.

### Standard R Code Template
```r
# Assumes data 'df' with columns: Category, Value, Group, Label
ggplot(df, aes(x = Category, y = Value, fill = Group)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8), width = 0.7) +
  # CRITICAL: Text repulsion
  geom_text_repel(
    aes(label = Label, group = Group),
    position = position_dodge(width = 0.8),
    vjust = -0.5,
    direction = "y",
    box.padding = 0.5,
    segment.color = "grey50"
  ) +
  # Publication Theme
  theme_pubr() +
  scale_fill_npg() +  # Nature Publishing Group colors
  labs(x = "Condition", y = "Normalized Expression") +
  theme(
    legend.position = "top",
    axis.text.x = element_text(angle = 45, hjust = 1) # Rotate x labels if long
  )
```

## 3. Python Implementation

Use **Python** with `matplotlib` and `seaborn` when integrating with Python-based pipelines (Scanpy, etc.).

### Required Libraries
```python
import matplotlib.pyplot as plt
import seaborn as sns
import scienceplots  # CRITICAL: For journal styling
from adjustText import adjust_text  # CRITICAL: For text repulsion
```

### Best Practices Checklist
1.  **Style**: ALWAYS use `plt.style.use(['science', 'nature'])` (requires `scienceplots` package).
2.  **Text Avoidance**:
    -   Collect all text objects in a list.
    -   Call `adjust_text(texts, arrowprops=dict(arrowstyle='->', color='red'))` at the end.
3.  **Cleanliness**:
    -   `sns.despine()` to remove top/right spines if not using `scienceplots`.
    -   Resolution: `plt.savefig(..., dpi=300, bbox_inches='tight')`.

### Standard Python Code Template
```python
import matplotlib.pyplot as plt
import seaborn as sns
from adjustText import adjust_text
import pandas as pd

# Activate SciencePlots style
try:
    plt.style.use(['science', 'nature'])
except:
    sns.set_theme(style="ticks") # Fallback

fig, ax = plt.subplots(figsize=(6, 4))
barplot = sns.barplot(data=df, x='Category', y='Value', hue='Group', ax=ax, palette='npg')

# Add Labels with adjustText
texts = []
for p in ax.patches:
    if p.get_height() > 0: # Only label visible bars
        t = ax.text(
            p.get_x() + p.get_width() / 2., 
            p.get_height(), 
            f'{p.get_height():.2f}', 
            ha='center', 
            va='bottom'
        )
        texts.append(t)

# Smart adjustment
adjust_text(texts, ax=ax, arrowprops=dict(arrowstyle='-', color='gray', lw=0.5))

plt.xlabel("Condition")
plt.ylabel("Expression")
plt.savefig("publication_barchart.pdf", dpi=300, bbox_inches='tight')
```

## 4. Common Pitfalls to Avoid
-   **DO NOT** manually calculate label positions (e.g., `y + 0.5`). It breaks when data changes.
-   **DO NOT** use default "rainbow" colors. They are unprofessional and often colorblind-unfriendly.
-   **DO NOT** let legends cover data. Move legends to 'top' or 'right' outside the plot area.
