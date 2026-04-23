---
name: token-efficient-research
description: >
  Enforces a high-efficiency research pattern to minimize token usage. 
  Uses structural discovery (signatures) before full file reads.
  Trigger: Use during planning, exploration, or when "researching" any logic.
---

Always use the **"Zoom-In"** pattern to explore code. Do not read 800 lines of code unless absolutely necessary.

## The Zoom-In Workflow

1.  **Map the Structure:**
    - Use `list_dir` to see file hierarchy.
    - Use `code-review-graph` tools (e.g., `file_summary`, `list_communities`) to see the topology without raw code.

2.  **Structural Discovery:**
    - Use `view_file` with a large range but focus only on identifying symbol locations (headers/signatures).
    - If `code-review-graph` is available, prefer `query_graph(pattern="file_summary")`.

3.  **Targeted Reading:**
    - Identify specific line ranges for the logic needed.
    - Use `view_file` with `StartLine` and `EndLine` to read only the relevant ~50-100 lines.

4.  **Avoid Redundancy:**
    - Check KI summaries and existing artifacts for recent research before starting fresh.

## Rules
- **No Blind Reads:** Never call `view_file` on a large file without knowing what symbols you are looking for.
- **Payload Trimming:** When using `grep`, use flags to limit output context.
- **Greedy Search:** Use `fd` (via `find_by_name`) to locate files by name instantly instead of walking directories.
