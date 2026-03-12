---
name: nsfc-grant
description: Write, review, and deeply restructure Chinese NSFC (国家自然科学基金/国自然/NSFC) proposals (青年/面上等). Use for module drafting and paragraph-level polishing across 立项依据/研究内容/研究方案/创新点/预期成果/研究基础 with review gates while keeping original data unchanged. Includes templates/examples plus a NIH RePORTER search script for idea scouting (immunology-friendly).
---

# 国自然申请书写作与深度修改（NSFC）

## 工作方式（必须遵守）
- 默认分段推进：每次只处理一个小节或一组段落。
- 每轮输出三块：改写稿 / 建议 / 需确认。
- 未经用户明确指令（如“写入/替换/应用/继续/下一步”），不改文件、不挪动段落。
- 初步数据不改动（数值、样本量、显著性、结论方向）；只优化表述、逻辑、摆放与图注。

## 写作素材与模板（已内置）

- 模块模板（逐模块生成）：`templates/01_rationale.md` `templates/02_research_content.md` `templates/03_methodology.md` `templates/04_innovations.md` `templates/05_expected_outcomes.md` `templates/06_research_basis.md`
- 评审打分与修改清单：`templates/07_review_criteria.md`
- 免疫学方向资料：`immunology/tumor_immunity.md` `immunology/inflammation.md`
- 高质量示例：`examples/section_examples.md`

## 启动时最少信息
- 项目类型：青年/面上（默认青年）。
- 研究对象：物种/模型/核心通路与关键分子。
- 有无硬性模板与字数限制（如无，默认精炼、可读、逻辑紧）。

## 主要工作流

### 工作流A：新申请书撰写（逐模块）

按模块生成并逐轮打磨：

1. 立项依据（参考 `templates/01_rationale.md`）
2. 研究内容（参考 `templates/02_research_content.md`）
3. 研究方案（参考 `templates/03_methodology.md`）
4. 创新点（参考 `templates/04_innovations.md`）
5. 预期成果（参考 `templates/05_expected_outcomes.md`）
6. 研究基础（参考 `templates/06_research_basis.md`）

每个模块产出后，用 `templates/07_review_criteria.md` 自评打分并按短板回炉一次。

### 工作流B：已有申请书深度修改（重排+逐段润色）

目标：用“主线叙事 + 三目标对齐”把全文改成评审好读、好抓要点的版本。

- 先给“结构诊断”：指出断点/冗余/缺口/顺序问题（不直接挪动）。
- 再做“逐段改写”：保持数据不变、语气克制、逻辑更紧。
- 需要重排时：给出“挪动清单 + 预期收益”，等待用户确认后再执行。

## 立项依据（Hook）
目标：用宏观知识空白驱动中心假说。

推荐顺序：研究意义 → 国内外现状 → 关键缺口(Knowledge Gap) → 科学问题(宏观) → 科学假设(中心假说)

写作要点：
- 关键缺口：解释“为什么过去研究停在现象/为什么机制没打通”。
- 科学问题（宏观）：概念性、领域级；回答“若不解决会卡住什么进展”；不写成实验清单。
- 科学假设：因果链条清晰、可检验；避免“将证明/决定性/必然”。

## 研究内容（Deliver）
目标：把宏观问题拆成可实验验证的机制抓手。

- 建议用“总体目标 + 3个具体目标”，并让以下部分逐条对齐：
  - 研究内容 2.1/2.2/2.3
  - 研究方案 4.1/4.2/4.3
  - 特色与创新 5
  - 年度计划 6
  - 预期结果 7
  - 研究基础 1.1（按证据链支撑每个目标）

写法分工：
- 2.*：写“要解决什么 + 总体策略/读出”，避免细节参数。
- 4.*：写“怎么做”，并为每个4.x补齐：关键判断点 / 预期结果 / 备选方案。

“拟解决的关键科学问题”（研究内容部分）：
- 必须微观、机制性、可验证，2–3条，并与2.1–2.3一一对应。

## 研究方案（4.*）的补全标准
对每个4.x段落，确保包含：
- 关键判断点：判定标准与因果证据。
- 预期结果：假设成立时应观察到的方向性结果。
- 备选方案：不显著/技术瓶颈/非特异效应时的替代路线。

## 研究基础（Feasibility）
目标：用“证据链+可行性”支撑中心假说与三目标。

建议组织：
- 1.1 初步结果按证据链排列：
  1) 功能效应（是否有效、是否依赖效应分子）
  2) 迁移/定位（炎症依赖性、时间动态）
  3) 关键轴候选（受体/配体双侧变化）
  4) 迁移前功能设定（是否在出发前已增强）
  5) 体腔可溶性信号线索（环境可诱导）
  6) 上游因子再现实验（如IL-12可同时诱导效应与迁移表型）
- 每条初步结果段落固定写法：关键观察 → 科学含义（用“提示/支持”） → 对应支撑哪个具体目标/关键判断点。
- 1.2 技术条件：2–4句写清模型/分选/示踪/组织学/流式/因子检测/转录组能力。
- 1.3 风险与应对：3–5条，直接对应4.*的关键风险点。

## 语言与风格（强约束）
- 避免AI化词汇与夸张承诺：不要写“将证明/决定性/必须/机制闭环”等。
- 禁用词（默认不出现在正文中）：框架、回路、节点、藕联、断路、放大器。
- 结论语气：用“提示/支持/一致/符合/为…提供依据”；机制用“拟阐明/拟解析/拟检验必要性”。

## NIH RePORTER 项目搜索（对标与找灵感）

用途：快速查看 NIH 已资助项目的题目/PI/机构/摘要/经费，辅助你校准创新点与可行性写法。

脚本：`scripts/nih_reporter_search.py`

依赖：`requests`（如报错缺失，可 `pip install requests`）。

用法：
```bash
# 在 nsfc-grant/ 目录内运行：
python scripts/nih_reporter_search.py "macrophage tumor immunity" --limit 5
python scripts/nih_reporter_search.py "NLRP3 inflammasome" --limit 10
python scripts/nih_reporter_search.py "CAR-T therapy" --year 2024
python scripts/nih_reporter_search.py "tumor microenvironment" -n 5 -o ./nih_results.md

# 或在 skills 根目录运行：
python nsfc-grant/scripts/nih_reporter_search.py "macrophage tumor immunity" --limit 5
```

输出：项目标题、PI、机构、资助金额、摘要、项目链接（可导出 Markdown）。

## 每轮输出模板
- 改写稿：给可直接替换的文本（不改数据）。
- 建议：需要增/删/挪动的点（不直接执行挪动）。
- 需确认：1–3个选择题（给默认推荐）。

## 快速自检
- 立项依据是否形成单线叙事并自然推出中心假说？
- 三个具体目标是否贯穿并全篇对应？
- 每个4.x是否都有关键判断点/预期/备选？
- 初步结果是否按证据链摆放并明确支撑哪一目标？
- 全文是否无禁用词、无夸张承诺、术语与图注统一？
