# spatial-transcriptomics

## Overview / 概览

`spatial-transcriptomics` is a single entrypoint skill for end-to-end spatial transcriptomics analysis using Scanpy, Squidpy, SpatialData, and related Python tooling.

`spatial-transcriptomics` 现在是一个单一入口 skill，用来覆盖空间转录组常见分析流程，包括数据导入、QC、邻域图、空间统计、组织区域识别、可视化，以及按需进行通信分析和去卷积。

## Included / 包含内容

- Top-level `SKILL.md` with the workflow guidance
- A lightweight `README.md` for quick public orientation

## Best For / 适用场景

- Visium, Xenium, MERFISH, Slide-seq, Stereo-seq, and related platforms
- Users who want one spatial workflow instead of many nested sub-skills
- Projects that need loading, QC, domains, visualization, and optional downstream spatial interpretation

## Notes / 说明

The earlier nested spatial sub-skills were removed to keep the repository leaner. The public repo now keeps only the single top-level spatial workflow skill.
