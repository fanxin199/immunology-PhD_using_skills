"""
Squidpy Spatial Viz - 通用工具函数
==================================
"""

import matplotlib.pyplot as plt
import os

# ====================
# 发表级图形参数
# ====================
PUBLICATION_PARAMS = {
    'figure.dpi': 150,
    'savefig.dpi': 300,
    'font.family': 'Arial',
    'font.size': 12,
    'axes.linewidth': 1.2,
    'axes.titlesize': 14,
    'axes.labelsize': 12,
    'xtick.labelsize': 10,
    'ytick.labelsize': 10,
    'legend.fontsize': 10,
}

def set_publication_style():
    """设置发表级图形样式"""
    plt.rcParams.update(PUBLICATION_PARAMS)
    print("✅ 已设置发表级图形样式")

def save_figure(fig, filename, output_dir="figures", formats=['svg', 'png', 'pdf'], dpi=300):
    """
    保存发表级图形
    
    Parameters
    ----------
    fig : matplotlib.figure.Figure
        图形对象
    filename : str
        文件名（不含扩展名）
    output_dir : str
        输出目录
    formats : list
        输出格式列表
    dpi : int
        分辨率
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    for fmt in formats:
        filepath = os.path.join(output_dir, f"{filename}.{fmt}")
        fig.savefig(
            filepath,
            dpi=dpi,
            bbox_inches='tight',
            facecolor='white',
            edgecolor='none'
        )
    
    print(f"✅ 已保存: {filename} ({', '.join(formats)})")

# ====================
# 配色方案
# ====================
# 发表级配色（与ggsci兼容的颜色值）
PALETTES = {
    'npg': ['#E64B35', '#4DBBD5', '#00A087', '#3C5488', '#F39B7F', 
            '#8491B4', '#91D1C2', '#DC0000', '#7E6148', '#B09C85'],
    'lancet': ['#00468B', '#ED0000', '#42B540', '#0099B4', '#925E9F',
               '#FDAF91', '#AD002A', '#ADB6B6', '#1B1919'],
    'nejm': ['#BC3C29', '#0072B5', '#E18727', '#20854E', '#7876B1',
             '#6F99AD', '#FFDC91', '#EE4C97'],
}

def get_palette(name='npg', n=None):
    """获取配色方案"""
    colors = PALETTES.get(name, PALETTES['npg'])
    if n:
        return colors[:n]
    return colors

# ====================
# 图形尺寸参考
# ====================
FIGURE_SIZES = {
    'single_panel': (6, 6),
    'double_panel': (12, 6),
    'triple_panel': (15, 5),
    'quad_panel': (12, 12),
    'wide': (10, 5),
    'tall': (6, 10),
}

def get_figure_size(layout='single_panel'):
    """获取预设图形尺寸"""
    return FIGURE_SIZES.get(layout, (6, 6))
