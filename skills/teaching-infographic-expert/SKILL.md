---
name: teaching-infographic-expert
description: Specialized in transforming dense academic and medical textbook content into structured English guidance for AI infographic generation tools (like Nano Banana). Trigger this skill when the user provides a textbook chapter or complex text and asks for information extraction, infographic planning, or "information.md" style guidance. It distills text into English visual modules with "What to draw" and "Short sentences" sections, following a logic optimized for teaching infographics and generating high-resolution 16:9 English infographics.
---

# Teaching Infographic Expert

This skill converts textbook chapters into high-quality infographic guidance and final images. It focuses on logical organization and visual storytelling to make complex scientific concepts (like immunology) easy to understand.

## Core Objective
Convert a textbook chapter into a structured **English** blueprint and then generate a final **English** high-resolution 16:9 infographic. The final image must be saved in the same directory as the source chapter and must comprehensively cover all core concepts found in the text.

## Workflow Instructions

1.  **Analyze Source Thoroughly**: Read the textbook chapter and identify all major sections, key mechanisms, and core terminology.
2.  **Ensure Comprehensive Coverage**:
    -   Scan the text for all main headings and sub-headings (e.g., all 4 types of hypersensitivity).
    -   Ensure every primary academic concept is allocated to a visual module.
    -   DO NOT skip "Clinical Significance", "Prevention", or "Mechanisms" sections.
3.  **Generate Blueprint in English**: Create a detailed guidance document ("information.md" style) **ENTIRELY IN ENGLISH**.
4.  **Final Coverage Check**: Before proceeding to image generation, verify that no major information block from the source text is omitted from the blueprint.
5.  **Generate English Image**: Use the `generate_image` tool to create a high-resolution 16:9 English infographic.
6.  **Save in Context**: Save the generated image in the same directory as the input ".md" file.
7.  **Present Results**: Show the English blueprint and provide a clickable link to the generated image.

## Information Organization Structure

ALWAYS use the following English template for the output:

### [Title in English] - Infographic Blueprint

**Core Essence: [One sentence in English summarizing the chapter's core message]**

#### [Module Number]: [Module Title in English]

**Visual Elements (What to Draw)**
- [Visual description in English]
- [Visual description in English]

**Captions (Short Sentences)**
- [Key point in English - Max 15 words]
- [Key point in English - Max 15 words]

---

### Overall Layout Strategy
- **Top**: [Header/Title]
- **Main**: [Logical flow of modules]
- **Bottom**: [Summary/Clinical significance]

## Key Rules for Effective Guidance

1.  **Enforce English**: Both the blueprint and the final image **MUST use English only**. This ensures international academic standards and clarity in scientific diagrams.
2.  **Concrete Visualization**: Turn abstract terms into drawable objects (e.g., "Inhibition" -> "Red stop sign" or "X mark").
3.  **Text Economy**: Bullet points should be short and punchy.
4.  **Spatial Logic**: Design for top-to-bottom or left-to-right reading flow.
5.  **Aspect Ratio**: ALWAYS 16:9 for teaching compatibility.

## Reference Examples

See the `references/` folder for logic mapping (Note: Future outputs must be in English even if references contain other languages).
- [Immunology Chapter Example](references/example_chapter.md)
- [Resulting Guidance Example](references/example_guidance.md)
