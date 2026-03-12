"""
Squidpy Spatial Viz - 邻域分析可视化模板
=========================================
用途：展示空间邻域富集、共现分析结果
"""

import squidpy as sq
import scanpy as sc
import matplotlib.pyplot as plt
import os

# 发表级设置
plt.rcParams['figure.dpi'] = 150
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.family'] = 'Arial'
plt.rcParams['font.size'] = 11

def save_figure(fig, filename, output_dir="figures", formats=['svg', 'png', 'pdf']):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    for fmt in formats:
        fig.savefig(os.path.join(output_dir, f"{filename}.{fmt}"), 
                    dpi=300, bbox_inches='tight', facecolor='white')
    print(f"✅ 已保存: {filename}")

# ====================
# 加载数据
# ====================
print("正在加载数据...")
adata = sq.datasets.visium_hne_adata()

# ====================
# 1. 构建空间邻域图
# ====================
print("构建空间邻域图...")
sq.gr.spatial_neighbors(adata, coord_type="generic", delaunay=True)

# ====================
# 2. 邻域富集分析
# ====================
print("计算邻域富集...")
sq.gr.nhood_enrichment(adata, cluster_key="cluster")

# 绑制邻域富集热图
fig, ax = plt.subplots(figsize=(8, 7))
sq.pl.nhood_enrichment(
    adata,
    cluster_key="cluster",
    method="average",
    cmap="RdBu_r",
    vmin=-50,
    vmax=50,
    ax=ax,
    title="Neighborhood Enrichment"
)
plt.tight_layout()
save_figure(fig, "nhood_enrichment")
plt.show()

# ====================
# 3. 共现分析
# ====================
print("计算共现分析...")
sq.gr.co_occurrence(adata, cluster_key="cluster")

# 绑制共现图
fig, ax = plt.subplots(figsize=(8, 6))
sq.pl.co_occurrence(
    adata,
    cluster_key="cluster",
    clusters=["Hypothalamus_1", "Hypothalamus_2"],  # 选择特定聚类
    ax=ax
)
plt.title("Co-occurrence Analysis")
plt.tight_layout()
save_figure(fig, "co_occurrence")
plt.show()

# ====================
# 4. 中心性评分
# ====================
print("计算中心性评分...")
sq.gr.centrality_scores(adata, cluster_key="cluster")

fig, ax = plt.subplots(figsize=(10, 6))
sq.pl.centrality_scores(
    adata,
    cluster_key="cluster",
    ax=ax
)
plt.title("Centrality Scores")
plt.tight_layout()
save_figure(fig, "centrality_scores")
plt.show()

# ====================
# 5. Ripley's 统计
# ====================
print("计算 Ripley's 统计...")
sq.gr.ripley(adata, cluster_key="cluster", mode="L")

fig, ax = plt.subplots(figsize=(8, 6))
sq.pl.ripley(
    adata,
    cluster_key="cluster",
    ax=ax
)
plt.title("Ripley's L Function")
plt.tight_layout()
save_figure(fig, "ripley_L")
plt.show()

print("""
╔════════════════════════════════════════════════════════════╗
║  邻域分析可视化完成！                                      ║
║  - nhood_enrichment: 邻域富集热图                          ║
║  - co_occurrence: 共现分析图                               ║
║  - centrality_scores: 中心性评分                           ║
║  - ripley_L: Ripley's L 函数                               ║
╚════════════════════════════════════════════════════════════╝
""")
