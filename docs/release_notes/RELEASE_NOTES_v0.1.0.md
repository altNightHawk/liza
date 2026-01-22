# Liza v0.1.0

First public release (alpha version) of Liza: a peer-supervised, contract-driven multi-agent coding system centered on behavioral constraints and auditable state.

---

## Why Liza?

Single-agent coding fails at scale. Agents claim success without validation, modify tests to pass, silently expand scope, and spiral through random changes rather than admit difficulty. Process frameworks assume good-faith execution — Liza assumes predictable failure modes and designs constraints to suppress them.

The result: agents that can be trusted to work autonomously, with humans as exception handlers rather than constant reviewers.

---

## Highlights

- End-to-end runnable workflow with Planner, Coder, and Code Reviewer roles coordinated via YAML blackboard and git worktrees
- Behavioral contracts addressing 55+ documented LLM failure modes—usable in either pairing or multi-agent mode
- Supervisor-assigned work model for non-interactive operation, with approval provenance and reviewer-filtered merges
- Specification-as-contract: `done_when` criteria are tests, not suggestions

---

## Core Features

**Behavioral Contracts**
- Tier 0-3 rule hierarchy with explicit degradation under pressure
- State machine with forbidden transitions (can't skip gates or validation)
- Multi-agent mode contract with role boundaries as Tier 0 violations
- Anti-gaming clause closing loophole-finding as an exploit class

**Blackboard Coordination**
- Atomic state transitions via file locking
- Immutable history (append-only)
- Structured communication fields (no agent conversation)
- Schema validation on every update

**Three-Role Architecture**
- **Planner**: Decomposes goals into tasks with specs; cannot implement
- **Coder**: Implements against specs with TDD; cannot self-approve or merge
- **Code Reviewer**: Approves, rejects, or merges; cannot implement

**Task Lifecycle**
- Pre-execution checkpoints capturing intent before implementation
- TDD enforcement: Code Reviewer rejects submissions without tests
- Worktree-based task isolation
- Integration merge flow with conflict escalation

---

## Tooling

CLI scripts to initialize, run, validate, and monitor Liza (`scripts/`):

| Script | Purpose |
|--------|---------|
| `liza-init.sh` | Initialize blackboard with goal and sprint |
| `liza-agent.sh` | Supervisor for Planner, Coder, or Code Reviewer |
| `liza-validate.sh` | Schema validation for blackboard state |
| `liza-watch.sh` | Monitor blackboard and alert on anomalies |
| `liza-claim-task.sh` | Atomic two-phase task claiming |
| `liza-submit-for-review.sh` | Submit task for Code Reviewer |
| `liza-submit-verdict.sh` | Code Reviewer submits approval/rejection |
| `wt-create.sh` / `wt-merge.sh` / `wt-delete.sh` | Worktree management |
| `liza-checkpoint.sh` | Sprint checkpoints with summaries |

---

## Documentation & Specs

- **Specifications** (`specs/`): Vision, architecture, roles, state machines, blackboard schema, protocols
- **Documentation** (`docs/`): Usage guide, demo walkthrough (~15 min), troubleshooting manual
- **Contracts** (`contracts/`): Core behavioral contract, pairing mode, multi-agent mode, failure mode map

---

## Skills

10 reusable skills in `skills/`, each a standalone methodology integrated with the contract:

| Skill | Purpose |
|-------|---------|
| `debugging` | Hypothesis-driven debugging with fast path for obvious fixes |
| `code-review` | P0-P3 severity tiers, structured feedback format |
| `testing` | Test design principles, coverage strategy, TDD support |
| `software-architecture-review` | Pattern/smell analysis, structural evaluation |
| `spec-review` | Specification validation and gap detection |
| `systemic-thinking` | Root cause analysis, system-level reasoning |
| `code-cleaning` | Refactoring discipline, dead code removal |
| `adr-backfill` | Architecture Decision Record creation from existing code |
| `generic-subagent` | Delegation protocol for spawning focused subagents |
| `feynman` | Explain-to-understand technique for complex domains |

Skills execute within contract constraints — e.g., debugging skill's Fast Path still requires Intent Gate.

---

## Key Differentiators

| Aspect | Typical MAS | Liza |
|--------|-------------|------|
| Trust model | Process compliance | Failure mode suppression |
| Checkpoints | After implementation | Before and after |
| Role governance | Uniform personas | Asymmetric per failure mode |
| Debugging | Agents debug autonomously | Log anomaly → BLOCKED → escalate |
| Human role | In the loop | Exception handler |
| Spec adherence | Guideline | Contract (violations rejected) |

---

## Getting Started

```bash
git clone <repo> && cd liza

# Initialize blackboard with a goal
./scripts/liza-init.sh "Build a CLI tool that greets users"

# Walk through the demo
cat docs/DEMO.md
```

**Requirements**: Bash, Git, yq, Claude Code CLI

---

## Known Limitations (v0.1.0)

- **Single sprint scope**: One active sprint, one instance per role
- **Claude-only**: Tested with Claude Code; Codex support planned
- **Terminal-first**: No IDE integration or web UI
- **No parallel coders**: Single Coder at a time
- **Manual circuit breaker**: Human-triggered only; no automated halt on systemic failure patterns
- **No spec-writing assistance**: Planner decomposes existing specs; facilitated discovery is v2

---

## What's Next (v1.1)

- Architect role for system design review
- Spec-writing skill with scope elicitation
- Codex agent support
- Parallel coder support
- Automated circuit breaker
- Blackboard reset utility

---

## Philosophy

> "The contract defines what's forbidden; the shape that remains is where judgment lives."

Liza optimizes for trust, not speed. The overhead is intentional — it's cheaper than the rework cycles it prevents.

---

## Naming

**Lisa Simpson** (methodical, principled, occasionally preachy about doing things right) + **ELIZA** (the original conversational AI that proved structure could simulate depth).
