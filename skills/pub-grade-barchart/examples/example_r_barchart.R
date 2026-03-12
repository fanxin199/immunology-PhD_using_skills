library(ggplot2)
library(ggpubr)
library(ggrepel)
library(ggsci)

# 1. Simulate Bioinformatics Data (e.g., Expression levels)
set.seed(42)
df <- data.frame(
  Gene = rep(c("TP53", "KRAS", "EGFR", "MYC", "BRCA1"), each = 2),
  Condition = rep(c("Control", "Treatment"), 5),
  Expression = c(10, 12, 5, 25, 15, 14, 8, 30, 12, 11),
  SD = runif(10, 1, 3)
)
df$Label <- paste0("p=", round(runif(10, 0, 0.05), 3))

# 2. Publication-Ready Bar Chart
p <- ggplot(df, aes(x = Gene, y = Expression, fill = Condition)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8), width = 0.7, color = "black", size = 0.3) +
  geom_errorbar(aes(ymin = Expression - SD, ymax = Expression + SD), 
                position = position_dodge(width = 0.8), width = 0.2, size = 0.3) +
  
  # CRITICAL: Smart Label Placement
  geom_text_repel(
    aes(label = Label, group = Condition),
    y = df$Expression + df$SD, # Start repelling from top of error bar
    position = position_dodge(width = 0.8),
    vjust = -0.5,
    direction = "y",
    box.padding = 0.5,
    size = 3,
    segment.size = 0.2,
    segment.color = "grey50"
  ) +
  
  # Styling
  scale_fill_npg() + # Nature Publishing Group colors
  theme_pubr() +
  labs(
    title = "Gene Expression Analysis",
    subtitle = "Comparing Control vs Treatment Groups",
    y = "Normalized RPKM",
    x = NULL
  ) +
  theme(
    legend.position = "top",
    axis.text.x = element_text(angle = 45, hjust = 1, face = "italic"),
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

# Save
ggsave("example_r_barchart.pdf", p, width = 6, height = 5)
print(p)
