# immunology-PhD_using_skills

An open repository of reusable AI skills for immunology, bioinformatics, scientific writing, and presentation workflows.

这是一个面向科研场景的开源技能仓库，收录了免疫学、生物信息学、科研写作与学术表达相关的可复用 AI skills。仓库名保留了 `immunology-PhD_using_skills`，但实际覆盖范围比免疫学更广，包含图形绘制、空间转录组、文献汇报、基金写作和免疫受体分析等工作流。

## What This Repo Contains / 仓库内容

- Production-oriented skill folders under [`skills/`](skills)
- Bilingual reader-facing summaries under [`docs/skills/`](docs/skills)
- Original `SKILL.md`, scripts, references, assets, and agent metadata when available

## Repository Layout / 目录结构

```text
.
├─ skills/
│  ├─ biomedical-paper-writer/
│  ├─ bioviz-pro/
│  ├─ celltypist/
│  ├─ complexheatmap/
│  ├─ enhanced-volcano/
│  ├─ go-enrichment/
│  ├─ nsfc-grant/
│  ├─ paper-presentation/
│  ├─ pub-grade-barchart/
│  ├─ spatial-transcriptomics/
│  ├─ squidpy-spatial-viz/
│  ├─ teaching-infographic-expert/
│  └─ tcr-bcr-analysis/
└─ docs/
   └─ skills/
```

## How To Use / 使用方式

This repository documents and distributes the skills. The official usage pattern is simple:

1. Clone or download this repository.
2. Pick the skill folder you want from [`skills/`](skills).
3. Copy that folder into your local skill directory, for example `.claude/skills/<skill-name>`.
4. Trigger the skill from your AI workflow using the folder name or the matching description in `SKILL.md`.

本仓库只承诺这一种使用路径：从 `skills/` 中挑选需要的 skill 目录，复制到你自己的本地 skill 目录，例如 `.claude/skills/<skill-name>`。

## Skill Catalog / 技能目录

| Skill | Focus / 聚焦 | Stack | Best for / 适用场景 | Details |
| --- | --- | --- | --- | --- |
| `biomedical-paper-writer` | Biomedical manuscript writing / 生物医学论文写作 | Writing workflow, OCAR, IMRaD | Drafting and revising papers, sections, and submission material | [summary](docs/skills/biomedical-paper-writer.md) |
| `bioviz-pro` | Publication-grade bioinformatics figures / 发表级生信图形 | R, ggplot2, ggsci | Volcano, PCA, heatmap, survival, enrichment plots | [summary](docs/skills/bioviz-pro.md) |
| `celltypist` | Immune cell type annotation / 免疫细胞注释 | Python, CellTypist | Fast scRNA-seq cell identity labeling | [summary](docs/skills/celltypist.md) |
| `complexheatmap` | Advanced heatmap composition / 高级热图 | R, ComplexHeatmap | Multi-layer genomic heatmaps and annotations | [summary](docs/skills/complexheatmap.md) |
| `enhanced-volcano` | Differential expression volcano plots / 火山图 | R, EnhancedVolcano | Labeled, publication-ready DE figures | [summary](docs/skills/enhanced-volcano.md) |
| `go-enrichment` | GO interpretation workflow / GO 富集解释 | Markdown, Python-oriented guidance | ORA and ranked enrichment for immunology datasets | [summary](docs/skills/go-enrichment.md) |
| `nsfc-grant` | NSFC proposal drafting / 国自然申请书写作 | Chinese writing workflow, Python helper | Structured proposal drafting and revision | [summary](docs/skills/nsfc-grant.md) |
| `paper-presentation` | PDF-to-talk workflow / 论文报告与学习包 | Python, PPT/PDF tooling | Talk-ready decks and study packs from papers | [summary](docs/skills/paper-presentation.md) |
| `pub-grade-barchart` | Publication-quality bar charts / 发表级柱状图 | R and Python | Fast bar-chart generation for figures and supplements | [summary](docs/skills/pub-grade-barchart.md) |
| `spatial-transcriptomics` | End-to-end spatial analysis / 空间转录组单一工作流 | Python, Scanpy, Squidpy, SpatialData | Loading, QC, domains, stats, visualization, communication, deconvolution | [summary](docs/skills/spatial-transcriptomics.md) |
| `squidpy-spatial-viz` | Spatial plotting with Squidpy / Squidpy 可视化 | Python, Squidpy | Spatial scatter, overlays, feature maps | [summary](docs/skills/squidpy-spatial-viz.md) |
| `teaching-infographic-expert` | Textbook-to-infographic planning / 教学信息图策划 | English blueprinting, image generation workflow | Turning dense textbook content into visual teaching assets | [summary](docs/skills/teaching-infographic-expert.md) |
| `tcr-bcr-analysis` | Immune repertoire analysis / TCR/BCR 克隆型分析 | Python, scirpy, AnnData | Clonotypes, diversity, overlap, scRNA integration | [summary](docs/skills/tcr-bcr-analysis.md) |

## Spatial Transcriptomics Note / 空间转录组说明

`spatial-transcriptomics` is now published as a single top-level skill instead of a nested skill tree. It still covers the common spatial workflow, but the repository no longer carries the older 11 sub-skills underneath it.

`spatial-transcriptomics` 现在以单一顶层 skill 的形式发布，不再保留之前那 11 个嵌套子 skill；常见空间分析流程仍然保留在这个单一 skill 的说明中。

## Scope Notes / 范围说明

- The repository is reader-friendly, but the original skill content remains close to its working form.
- Bilingual coverage is provided at the repository layer and in the summary pages, not by fully translating every internal `SKILL.md`.
- Some skills are Chinese-first, some English-first, and many are intentionally mixed because they target real research workflows.

## Attribution And License / 署名与许可

Unless a subfolder says otherwise, this repository is released under the [MIT License](LICENSE).

Most skills are original, user-curated workflows. If a bundled component clearly derives from another public source, it should retain attribution in that subfolder or in future repository updates.
