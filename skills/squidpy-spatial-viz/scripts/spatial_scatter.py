"""
Squidpy Spatial Viz - 空间散点图模板
=====================================
用途：展示空间转录组数据的细胞/spot分布
支持：Visium, Xenium, Slide-seq 等平台
"""

import squidpy as sq
import scanpy as sc
import matplotlib.pyplot as plt
import os

# ====================
# 发表级图形设置
# ====================
plt.rcParams['figure.dpi'] = 150
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.family'] = 'Arial'
plt.rcParams['font.size'] = 12
plt.rcParams['axes.linewidth'] = 1.2

def save_figure(fig, filename, output_dir="figures", formats=['svg', 'png', 'pdf']):
    """保存发表级图形"""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    for fmt in formats:
        filepath = os.path.join(output_dir, f"{filename}.{fmt}")
        fig.savefig(filepath, dpi=300, bbox_inches='tight', facecolor='white')
    print(f"✅ 已保存: {filename} (.svg, .png, .pdf)")

# ====================
# 加载示例数据
# ====================
# 使用 Squidpy 内置的 Visium 示例数据
# 实际使用时替换为您的 AnnData 对象
print("正在加载示例数据...")
adata = sq.datasets.visium_hne_adata()
print(f"数据维度: {adata.shape}")

# ====================
# 示例1：基础空间散点图（按聚类着色）
# ====================
fig, ax = plt.subplots(figsize=(8, 8))
sq.pl.spatial_scatter(
    adata,
    color="cluster",
    size=1.3,
    alpha=0.8,
    ax=ax,
    title="Spatial Distribution by Cluster"
)
plt.tight_layout()
save_figure(fig, "spatial_scatter_cluster")
plt.show()

# ====================
# 示例2：基因表达空间图
# ====================
# 选择感兴趣的基因
genes = ["Gfap", "Mbp", "Nrgn"]  # 神经胶质/髓鞘/神经元标记

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
for i, gene in enumerate(genes):
    sq.pl.spatial_scatter(
        adata,
        color=gene,
        size=1.3,
        cmap="viridis",
        ax=axes[i],
        title=gene
    )
axes[0].set_ylabel("Spatial Y")
plt.tight_layout()
save_figure(fig, "spatial_gene_expression")
plt.show()

# ====================
# 示例3：叠加组织图像
# ====================
fig, ax = plt.subplots(figsize=(10, 10))
sq.pl.spatial_scatter(
    adata,
    color="cluster",
    img=True,  # 显示背景H&E图像
    size=1.0,
    alpha=0.7,
    ax=ax,
    title="Clusters Overlaid on H&E Image"
)
plt.tight_layout()
save_figure(fig, "spatial_with_image")
plt.show()

# ====================
# 示例4：多panel组合图
# ====================
fig, axes = plt.subplots(2, 2, figsize=(12, 12))

# 聚类分布
sq.pl.spatial_scatter(adata, color="cluster", ax=axes[0, 0], title="Clusters")

# 基因表达
sq.pl.spatial_scatter(adata, color="Gfap", cmap="Reds", ax=axes[0, 1], title="Gfap")
sq.pl.spatial_scatter(adata, color="Mbp", cmap="Blues", ax=axes[1, 0], title="Mbp")
sq.pl.spatial_scatter(adata, color="Nrgn", cmap="Greens", ax=axes[1, 1], title="Nrgn")

plt.tight_layout()
save_figure(fig, "spatial_multipanel")
plt.show()

print("""
╔════════════════════════════════════════════════════════════╗
║  空间散点图绑制完成！                                      ║
║  输出文件位于 figures/ 目录                                ║
╚════════════════════════════════════════════════════════════╝
""")
