# Liza - Usage Guide

## Activation of the Contract for Pairing Agents

Check [Genesis](../README.md#genesis) for the features.

Create symlinks:
```
- `~/.claude/CLAUDE.md` -> `~/Workspace/liza/contracts/CORE.md`
- `~/.claude/PAIRING_MODE.md` -> `~/Workspace/liza/contracts/PAIRING_MODE.md`
- `~/.claude/MULTI_AGENT_MODE.md` -> `~/Workspace/liza/contracts/MULTI_AGENT_MODE.md`
- `~/.claude/AGENT_TOOLS.md` -> `~/Workspace/liza/contracts/AGENT_TOOLS.md`
- `~/.claude/skills` -> `~/Workspace/liza/contracts/skills`
- `~/.claude/COLLABORATION_CONTINUITY.md` -> `~/Workspace/liza/contracts/COLLABORATION_CONTINUITY.md`
- `~/.claude/scripts` -> `~/Workspace/liza/scripts`
```

In `~/.claude/settings.json`, configure global permissions for tools used across all projects:

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Read(~/.claude/**)",

      "Skill(adr-backfill)",
      "Skill(code-cleaning)",
      "Skill(code-review)",
      "Skill(debugging)",
      "Skill(feynman)",
      "Skill(generic-subagent)",
      "Skill(software-architecture-review)",
      "Skill(spec-review)",
      "Skill(systemic-thinking)",
      "Skill(testing)",

      "mcp__Ref__ref_search_documentation",
      "mcp__Ref__ref_read_url",
      "mcp__perplexity__perplexity_ask",
      "mcp__deepwiki__read_wiki_structure",
      "mcp__deepwiki__read_wiki_contents",
      "mcp__deepwiki__ask_question",
      "mcp__context7__resolve-library-id",
      "mcp__context7__query-docs",
      "mcp__fetch__fetch",
      "mcp__sequential-thinking-tools__sequentialthinking_tools",

      "mcp__filesystem__read_file",
      "mcp__filesystem__read_text_file",
      "mcp__filesystem__read_media_file",
      "mcp__filesystem__read_multiple_files",
      "mcp__filesystem__list_directory",
      "mcp__filesystem__list_directory_with_sizes",
      "mcp__filesystem__directory_tree",
      "mcp__filesystem__search_files",
      "mcp__filesystem__get_file_info",
      "mcp__filesystem__list_allowed_directories",

      "mcp__jetbrains__list_directory_tree",
      "mcp__jetbrains__get_run_configurations",
      "mcp__jetbrains__get_file_problems",
      "mcp__jetbrains__get_project_dependencies",
      "mcp__jetbrains__get_project_modules",
      "mcp__jetbrains__find_files_by_glob",
      "mcp__jetbrains__find_files_by_name_keyword",
      "mcp__jetbrains__get_all_open_file_paths",
      "mcp__jetbrains__get_file_text_by_path",
      "mcp__jetbrains__search_in_files_by_regex",
      "mcp__jetbrains__search_in_files_by_text",
      "mcp__jetbrains__get_symbol_info",
      "mcp__jetbrains__get_repositories",
      "mcp__jetbrains__open_file_in_editor",
      "mcp__jetbrains__execute_run_configuration",
      "mcp__jetbrains__create_new_file",
      "mcp__jetbrains__replace_text_in_file",
      "mcp__jetbrains__reformat_file",
      "mcp__jetbrains__rename_refactoring",
      "mcp__jetbrains__execute_terminal_command",
      "mcp__jetbrains__runNotebookCell",

      "mcp__morph-mcp__edit_file",
      "mcp__morph-mcp__warpgrep_codebase_search",

      "mcp__postgres__query",

      "WebFetch",
      "WebSearch",
      "LSP",

      "Bash(~/.claude/scripts/*)",
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Bash(jq:*)",
      "Bash(yq:*)",
      "Bash(sort:*)",
      "Bash(uniq:*)",
      "Bash(cut:*)",
      "Bash(tr:*)",
      "Bash(diff:*)",
      "Bash(realpath:*)",
      "Bash(dirname:*)",
      "Bash(basename:*)",
      "Bash(which:*)",
      "Bash(file:*)",
      "Bash(tree:*)",
      "Bash(env:*)",
      "Bash(printenv:*)",
      "Bash(gh:*)",
      "Bash(git commit:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git show:*)",
      "Bash(git branch:*)",
      "Bash(git blame:*)",
      "Bash(git ls-files:*)",
      "Bash(git grep:*)",
      "Bash(pre-commit:*)",
      "Bash(python:*)",
      "Bash(python3:*)",
      "Bash(pytest:*)",
      "Bash(shellcheck:*)",
      "Bash(bash:*)",
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(wc:*)",
      "Bash(date:*)",
      "Bash(find:*)",
      "Bash(grep:*)"
    ]
  }
}
```

**Permission categories:**
- `"defaultMode": "acceptEdits"` — Required for Liza agents to work headless (preferred to `"bypassPermissions"` aka YOLO mode)
- `Read(~/.claude/**)` — Access to contract files
- `Bash(~/.claude/scripts/*)` — Execution of Liza scripts
- `Skill(...)` — Custom skills from `~/.claude/skills/`
- `mcp__...` — Your configured MCP tools
- `WebFetch/WebSearch/LSP` — Built-in Claude tools for web and code navigation
- Other `Bash(...)` — Safe read-only shell commands (no package managers)

This enables auto-accept mode for headless agents. If agents get blocked on additional tools, add them to your global settings. Refer to "Debug a stuck agent interactively" in [DEMO.md](DEMO.md#troubleshooting) to identify blocking commands.

Verification:
- Run `claude`
- Prompt `hello`

## Liza

See [DEMO](DEMO.md) for a full example.

### Quick Start (Target Usage)

**Prerequisites:**
- Claude Code CLI installed
- `yq` installed (YAML processor)
- Git installed
- Project with `specs/vision.md` describing the goal

**1. Initialize**
```bash
# Create .liza/ directory with blackboard
~/.claude/scripts/liza-init.sh "[Goal description]" [spec_ref]

# spec_ref: Path to goal specification (default: specs/vision.md)
# Examples:
#   liza-init.sh "Implement retry logic"                    # uses specs/vision.md
#   liza-init.sh "Add auth" specs/auth-feature.md           # uses custom spec

# Verify
cat .liza/state.yaml
```

**2. Start Agents (3 terminals)**

Terminal 1 — Planner:
```bash
LIZA_AGENT_ID=planner-1 ~/.claude/scripts/liza-agent.sh planner
```

Terminal 2 — Coder:
```bash
LIZA_AGENT_ID=coder-1 ~/.claude/scripts/liza-agent.sh coder
```

Terminal 3 — Code Reviewer:
```bash
LIZA_AGENT_ID=code-reviewer-1 ~/.claude/scripts/liza-agent.sh code-reviewer
```

**3. Observe**
```bash
# Run the watcher for alerts
~/.claude/scripts/liza-watch.sh
```

```bash
# Watch blackboard state
watch -n 2 'yq ".tasks[] | pick([\"id\", \"status\", \"description\"])" .liza/state.yaml'
```

**4. Human Interventions**
```bash
# Pause all agents
touch .liza/PAUSE

# Resume
rm .liza/PAUSE

# Abort
touch .liza/ABORT

# Checkpoint (halt + generate summary)
~/.claude/scripts/liza-checkpoint.sh "End of sprint 1"
```

**5. Review Results**
```bash
# Activity log
cat .liza/log.yaml

# Integration branch
git log integration --oneline
```

### Helper Scripts

The supervisor (`liza-agent.sh`) uses helper scripts for state transitions:

| Script | Purpose |
|--------|---------|
| `liza-claim-task.sh <task-id> <agent-id>` | Atomically claim a task for a coder (creates worktree, updates state) |
| `liza-validate.sh <state.yaml>` | Validate blackboard state against schema invariants |
| `liza-watch.sh` | Monitor blackboard and alert on anomalies |
| `liza-checkpoint.sh <message>` | Create a checkpoint (halt + summary) |
| `liza-init.sh <goal> [spec_ref]` | Initialize .liza/ directory with blackboard (spec_ref defaults to specs/vision.md) |

**Important:** The supervisor claims tasks *before* starting the Claude agent. This avoids interactive permission prompts in `-p` (non-interactive) mode. Agents receive their assigned task in the bootstrap prompt and should NOT call claim scripts directly.

See [Architecture Overview](../specs/architecture/overview.md) for detailed component descriptions.
