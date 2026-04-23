---
name: code-mode-repl
description: >
  Prioritizes script execution (Code Mode) over manual multi-step tool calls.
  Use when performing complex data transformations, multi-file searches, or batch operations.
---

When a task requires more than 3-5 individual tool calls that follow a predictable logic, **write a script instead.**

## Workflow

1.  **Draft the Logic:** Write a concise Shell (`.sh`) or Python (`.py`) script in `/tmp/`.
2.  **Single-Call Execution:** Run the script using `run_command`.
3.  **Clean Up:** Delete the temporary script after the result is captured.

## Use Cases

- **Batch File Editing:** Instead of 15 `replace_file_content` calls, use `sed` or a Python script to patch files.
- **Complex Aggregation:** Use `find` + `grep` + `awk` in one command to extract structured data from logs or code.
- **Environment Checks:** Run a suite of `analyze`, `test`, and `lint` checks in a single background command.

## Rules
- **Safety First:** Never auto-run commands (`SafeToAutoRun: true`) that delete non-temp files or modify state without review.
- **Output Control:** Ensure the script prints concise results. Use `tail`, `grep`, or `jq` to trim large outputs.
- **Persistence:** If a script is high-value, save it as a "Workflow" in the `.agents/workflows/` directory.
