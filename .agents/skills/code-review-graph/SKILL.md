---
name: code-review-graph
description: >
  Graph-powered code exploration and review. Uses the code-review-graph MCP server to 
  perform structural impact analysis, identify architectural hotspots, and provide 
  context-aware reviews. Use when analyzing dependencies, assessing change risks, 
  performing complex refactors, or conducting thorough code reviews.
---

Use the `code-review-graph` MCP server to understand the codebase beyond simple text matching.

## Core Workflows

### 1. Ultra-Lean Status Check
Always start with the minimal context to save tokens.
- **Tool:** `get_minimal_context_tool(task="...", repo_root="...")`
- **Result:** ~100 tokens. Gives high-level risk, stats, and next-step suggestions.

### 2. Pre-Implementation Impact Analysis
Before making changes, understand what might break.
- **Tool:** `get_impact_radius_tool(changed_files=[...], max_depth=2, detail_level="minimal")`
- **Goal:** Identify downstream dependencies and potential regressions with minimal payload.

### 2. Semantic Navigation
Find code by meaning, not just exact keywords.
- **Tool:** `semantic_search_nodes_tool(query="...", kind="Function")`
- **Goal:** Locate relevant logic when file names are ambiguous.

### 3. Change-Aware Review
Review your own or others' changes with awareness of affected flows.
- **Tool:** `detect_changes_tool(base="HEAD~1")`
- **Tool:** `get_review_context_tool(include_source=True)`
- **Goal:** Get a prioritized list of review items based on risk and connectivity.

### 4. Architectural Discovery
Understand how the codebase is structured into communities.
- **Tool:** `list_communities_tool(detail_level="minimal")`
- **Tool:** `get_architecture_overview_tool()`
- **Goal:** Identify hotspots (hub nodes) and bridge nodes that couple disparate systems.

## Rules

- **Signatures-First:** When exploring, use `query_graph(pattern="file_summary", detail_level="minimal")` to see function/class signatures before reading full code.
- **Initialize First:** If the graph doesn't exist or is stale, run `build_or_update_graph_tool(postprocess="minimal")`.
- **Prefer Minimal Context:** Use `get_minimal_context_tool()` for an ultra-compact status update on any task.
- **Cross-Repo:** If working in a multi-repo workspace, use `cross_repo_search_tool()`.
- **Refactoring:** Use `refactor_tool(mode="rename")` to preview symbol renames across the entire graph.

## When to Trigger
- "What's the impact of changing X?"
- "Review my changes."
- "Where is the logic for Y?"
- "Find dead code." (`refactor_tool(mode="dead_code")`)
- "Show me an overview of the architecture."
