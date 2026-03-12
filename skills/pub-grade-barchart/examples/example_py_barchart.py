import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
from adjustText import adjust_text

# 1. Simulate Bioinformatics Data
data = {
    'Gene': ['TP53', 'TP53', 'KRAS', 'KRAS', 'EGFR', 'EGFR', 'MYC', 'MYC'],
    'Condition': ['Control', 'Treatment', 'Control', 'Treatment', 'Control', 'Treatment', 'Control', 'Treatment'],
    'Expression': [10.5, 13.2, 5.1, 22.4, 15.8, 14.2, 8.5, 32.1],
    'P_Value': [0.03, 0.03, 0.001, 0.001, 0.5, 0.5, 0.0001, 0.0001]
}
df = pd.DataFrame(data)

# 2. Setup Style (Publication Quality)
try:
    import scienceplots
    plt.style.use(['science', 'nature'])
except ImportError:
    print("Warning: scienceplots not installed. Using seaborn default.")
    sns.set_theme(style="ticks")

fig, ax = plt.subplots(figsize=(6, 5))

# 3. Plot Bar Chart
# Note: errorbar=None for simplicity, usually you'd calculate CIs
barplot = sns.barplot(
    data=df, 
    x='Gene', 
    y='Expression', 
    hue='Condition', 
    ax=ax, 
    palette='npg', # Requires valid palette names, 'npg' might need 'ggsci' python port or custom list. Fallback to 'deep'
    edgecolor='black',
    linewidth=0.5
)

# 4. Smart Labeling with adjustText
texts = []
for i, p in enumerate(ax.patches):
    if p.get_height() > 0:
        # Calculate label based on data index if needed, or just value
        # Ideally map patch back to data, but for simple labeling using height:
        label = f"{p.get_height():.1f}"
        
        # Add basic text
        t = ax.text(
            p.get_x() + p.get_width() / 2., 
            p.get_height(), 
            label, 
            ha='center', 
            va='bottom',
            fontsize=8
        )
        texts.append(t)

# Add p-value annotations (Manual example to show adjustText power)
# In reality, you'd calculate exact coordinates for brackets.
# Here we just add floating text to demonstrate repulsion.
for i, gene in enumerate(df['Gene'].unique()):
    # Mock position
    t = ax.text(i, df[df['Gene']==gene]['Expression'].max() + 5, f"p<{df[df['Gene']==gene]['P_Value'].min()}", color='red', fontsize=7)
    texts.append(t)

# 5. Apply adjust_text to PREVENT OVERLAP
adjust_text(
    texts, 
    ax=ax, 
    arrowprops=dict(arrowstyle='-', color='gray', lw=0.5),
    expand_points=(1.2, 1.2) # Push them a bit further
)

plt.xlabel("Gene Symbol")
plt.ylabel("Normalized Expression (TPM)")
plt.legend(loc='upper right', frameon=False)

# Clean spines if not handled by style
sns.despine()

plt.savefig("example_py_barchart.pdf", dpi=300, bbox_inches='tight')
print("Plot saved to example_py_barchart.pdf")
