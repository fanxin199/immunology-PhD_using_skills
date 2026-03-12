"""
Squidpy Spatial Viz - 空间特征图模板
====================================
用途：展示空间基因表达、组织特征
"""

import squidpy as sq
import scanpy as sc
import matplotlib.pyplot as plt
import numpy as np
import os

# 发表级设置
plt.rcParams.update({
    'figure.dpi': 150,
    'savefig.dpi': 300,
    'font.family': 'Arial',
    'font.size': 12,
})

def save_figure(fig, filename, output_dir="figures"):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    for fmt in ['svg', 'png', 'pdf']:
        fig.savefig(os.path.join(output_dir, f"{filename}.{fmt}"), 
                    dpi=300, bbox_inches='tight', facecolor='white')
    print(f"✅ 已保存: {filename}")

# ====================
# 加载数据
# ====================
print("正在加载数据...")
adata = sq.datasets.visium_hne_adata()

# ====================
# 1. 单基因空间特征图
# ====================
gene = "Gfap"  # 星形胶质细胞标记

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# 空间表达图
sq.pl.spatial_scatter(
    adata, color=gene, cmap="magma", size=1.5, ax=axes[0],
    title=f"{gene} - Spatial Expression"
)

# 小提琴图（按聚类）
sc.pl.violin(adata, keys=gene, groupby="cluster", ax=axes[1], show=False)
axes[1].set_title(f"{gene} Expression by Cluster")
axes[1].tick_params(axis='x', rotation=45)

plt.tight_layout()
save_figure(fig, f"spatial_feature_{gene}")
plt.show()

# ====================
# 2. 多基因空间图（marker genes）
# ====================
marker_genes = {
    "Astrocyte": "Gfap",
    "Oligodendrocyte": "Mbp",
    "Neuron": "Nrgn",
    "Microglia": "Aif1"
}

fig, axes = plt.subplots(2, 2, figsize=(12, 12))
axes = axes.flatten()

cmaps = ["Reds", "Blues", "Greens", "Purples"]

for i, (cell_type, gene) in enumerate(marker_genes.items()):
    if gene in adata.var_names:
        sq.pl.spatial_scatter(
            adata, color=gene, cmap=cmaps[i], size=1.2, ax=axes[i],
            title=f"{cell_type}\n({gene})"
        )
    else:
        axes[i].set_title(f"{gene} not found")
        axes[i].axis('off')

plt.tight_layout()
save_figure(fig, "spatial_marker_genes")
plt.show()

# ====================
# 3. 连续变量空间图（如总UMI计数）
# ====================
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# 总counts空间分布
sq.pl.spatial_scatter(
    adata, color="total_counts", cmap="YlOrRd", size=1.5, ax=axes[0],
    title="Total UMI Counts"
)

# 检测基因数空间分布
sq.pl.spatial_scatter(
    adata, color="n_genes_by_counts", cmap="YlGnBu", size=1.5, ax=axes[1],
    title="Genes Detected per Spot"
)

plt.tight_layout()
save_figure(fig, "spatial_qc_metrics")
plt.show()

# ====================
# 4. 自定义颜色映射
# ====================
from matplotlib.colors import LinearSegmentedColormap

# 创建自定义colormap（蓝-白-红）
custom_cmap = LinearSegmentedColormap.from_list(
    "custom_bwr", ["#2166AC", "#F7F7F7", "#B2182B"]
)

fig, ax = plt.subplots(figsize=(8, 8))
sq.pl.spatial_scatter(
    adata, color="Gfap", cmap=custom_cmap, size=1.5, ax=ax,
    title="Custom Colormap Example"
)
plt.tight_layout()
save_figure(fig, "spatial_custom_cmap")
plt.show()

print("""
╔════════════════════════════════════════════════════════════╗
║  空间特征图绑制完成！                                      ║
║  - spatial_feature_*: 单基因空间图                         ║
║  - spatial_marker_genes: 多marker基因组合图                ║
║  - spatial_qc_metrics: QC指标空间分布                      ║
║  - spatial_custom_cmap: 自定义配色示例                     ║
╚════════════════════════════════════════════════════════════╝
""")
