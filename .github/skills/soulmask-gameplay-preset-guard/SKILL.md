---
name: soulmask-gameplay-preset-guard
description: "Use when extracting or updating Soulmask gameplay settings from saraserenity.net/soulmask/gameplay_settings.php or similar tables. Prevents treating the site's Default column as Casual, and keeps site Default, 3-group values, and 5-difficulty values separate."
argument-hint: "Soulmask gameplay preset extraction"
user-invocable: true
disable-model-invocation: false
---

# Soulmask Gameplay Preset Guard

## Purpose
Use this skill when you are copying or updating Soulmask gameplay-setting presets from the gameplay_settings.php website, especially when a row contains both a site Default value and five difficulty columns.

## Core Rule
Never infer that the site's Default column is the Casual value.

Treat these as separate concepts:
- Site Default: the standalone value shown before the five difficulty columns
- Difficulty presets: Casual, Easy, Normal, Hard, Master
- Group presets: the three group values [0], [1], [2] used by the game and editor

## Required Workflow
1. Read the website row structure first.
2. Record the site Default separately from the five difficulty values.
3. Record any [0]/[1]/[2] group values separately from the difficulty values.
4. If a setting has group-specific differences, preserve them as a 3-group structure.
5. If a setting has both group and difficulty variation, store them as a 3×5 matrix or an equivalent explicit structure.
6. Only map a value to Casual when the website explicitly shows Casual in that position.

## Data Handling Rules
- Do not shift Default into Casual.
- Do not collapse three group defaults into a single difficulty row.
- Do not reuse a five-value difficulty array as if it also represented the three group defaults.
- If a row is group-independent, duplicate the same default across all groups explicitly rather than assuming the first value means Casual.
- If a row is group-dependent, keep the group values authoritative even when the difficulty values happen to look similar.

## Suggested Internal Shape
When writing code or data, prefer an explicit structure such as:
- `defaultValue`
- `groups: [group0, group1, group2]`
- `difficulties: [[casual, easy, normal, hard, master], ...]`

Use a structure like this whenever the source page distinguishes Default from difficulty columns or shows separate group values.

## Validation Checklist
Before finishing, verify:
- Default is not copied into Casual by accident
- Group 0, 1, and 2 values are preserved separately
- Casual, Easy, Normal, Hard, and Master stay in the correct order
- Count-based settings such as AnimalFollowerMaxCount and GongHuiMaxZhaoMuCount still match the website's row layout
- Existing JSON import/export remains compatible

## References
- Source page: https://saraserenity.net/soulmask/gameplay_settings.php
- Project editor: [GameXishuEditor.html](../../../GameXishuEditor.html)
