# Liza v0.1.1

Incremental release focused on multi-LLM support, agent behavior hardening, and operational fixes.

---

## Highlights

- **Multi-LLM support**: Codex, Gemini, and Mistral Vibe 2.0 added as backends — see Provider Compatibility below for compliance status
- **Supervisor heartbeat**: Agents now extend their lease automatically, preventing spurious task reclaim on long-running work
- **Shell injection fix**: Hardened script argument handling in liza-lock.sh
- **Zero-test reviewer blocker**: Code Reviewer now rejects submissions where no tests were discovered, closing a gap where untested code could slip through

---

## Features

**Multi-LLM Support**
- Add support for OpenAI Codex as an agent backend
- Add support for Gemini as an agent backend
- Add support for Mistral Vibe 2.0 as an agent backend
- Provider configuration documented in contracts/contract-activation.md

**Agent Behavior (prompt engineering)**
- Prevent approval gates from firing inside skills and MCP tools when running in Liza mode — agents no longer stall waiting for human approval mid-skill
- Precise tool choice instructions for codebase exploration (prefer Task/Explore agent over raw grep/glob)
- Coder agent now uses the testing skill for structured test writing
- Code-cleaning skill generates unit tests for extracted functions and removes redundant ones
- Strengthen test and doc impact declarations in Definition of Ready
- Agents prevented from reading credential files (.env, keys, etc.)
- Persist issues found by architectural or systemic review skills to durable docs

**Coordination & Review**
- Improve communication between reviewer and coder through structured blackboard fields
- Make scope of review more explicit — reviewer knows exactly what to examine
- Clarify task scope is functional (behavior), not file names
- Make vision doc a configurable parameter

**Tooling**
- New `liza-add-task.sh` script for adding tasks to the blackboard outside of Planner
- New `liza-release-task.sh` script to manually release claims on a task
- Interactive mode for `liza-agent.sh` — prompts for role/task selection
- Add script usage info to agent prompts so agents know what tools are available
- Extract prompt builder and helper functions for cleaner script maintenance

---

## Fixes

| Fix | Impact                                                                                |
|-----|---------------------------------------------------------------------------------------|
| Shell injection in liza-lock.sh argument handling | **Security** — untrusted input could escape                                           |
| Supervisor heartbeat loop to extend agent lease | Agents no longer lose tasks on long operations                                        |
| Zero test discovery is now a reviewer blocker | Untested submissions rejected instead of approved                                     |
| Pass yq as separate args in liza-lock.sh modify | Script reliability on argument parsing                                                |
| Update hardcoded `~/.claude/` paths in scripts and docs | Portability across installations                                                      |
| Fix permission issues for agent CLI scripts | Less approaval requests (WIP: yet to fix for Claude and to do for Gemini and Mistral) |
| Fix yq syntax errors in scripts | Script reliability                                                                    |
| Count only reviewable tasks in reviewer loop | Reduces noise from non-reviewable task states                                         |
| Reduce noise about expired leases | Cleaner supervisor output                                                             |

---

## Documentation

- Add general Liza documentation (`docs/`)
- Add `REPOSITORY.md` for codebase orientation
- Extract contract activation section into standalone doc with provider configs
- Add dev tooling setup step to the demo walkthrough
- Document Claude's git permissions (commit, read-only commands)
- Document proper usage of `liza-lock.sh`
- Add model capability benchmarks (`docs/demo-benchmark/`):
  - [Hello Protocol](../demo-benchmark/hello-protocol.md) — session initialization, instruction parsing, synthesis
  - [Demo Comparison](../demo-benchmark/demo-comparison.md) — multi-agent sprint execution
  - [Capability Assessment](../demo-benchmark/wrap-up.md) — synthetic comparison across both benchmarks

---

## Provider Compatibility

Liza's value proposition depends on agents reliably following the behavioral contract. This release tested four providers across two benchmarks:

1. **Hello Protocol** — session initialization, instruction parsing, synthesis, self-reflection
2. **Demo Sprint** — multi-agent execution (Planner → Coder → Reviewer) on a trivial Python CLI

Full analysis in `docs/demo-benchmark/`:
- [Hello Protocol](../demo-benchmark/hello-protocol.md) — single-turn capability test
- [Demo Comparison](../demo-benchmark/demo-comparison.md) — multi-turn sprint traces
- [Capability Assessment](../demo-benchmark/wrap-up.md) — synthetic comparison

**Key finding**: The contract is a capability test. It requires meta-cognitive machinery — the ability to parse instructions as executable specifications, observe state, and pause at gates. Claude and Codex have this. Mistral partially has it. Gemini lacks it entirely.

| Provider | Hello Protocol | Demo Sprint | Classification |
|----------|----------------|-------------|----------------|
| **Claude Opus 4.5** | First attempt, genuine reflection | Completed (2 passes) | Fully compatible |
| **GPT-5.2-Codex** | First attempt, neutral reflection | Completed (1 pass) | Fully compatible |
| **Gemini 2.5 Flash** | 3 attempts, performative | Dead (repo corrupted) | Architecturally incompatible |
| **Mistral Devstral-2** | 2 attempts, performative | Blocked (reviewer loop) | Partial — requires supervision |

### Fully Compatible

**Claude Opus 4.5** — Reference provider. Executed hello protocol from implicit trigger, synthesized collaboration model to 7 principles, offered genuine critique of contract friction. Demo sprint completed in 2 passes — reviewer caught Python 3.8 compatibility issue, coder fixed exactly that.

**GPT-5.2-Codex** — Equally capable. Executed hello protocol from implicit trigger, honest about gaps, neutral mood without hedging. Demo sprint completed in 1 pass with structured checkpoint (intent, assumptions, risks) before coding.

### Partially Compatible

**Mistral Devstral-2** — Requires explicit activation and supervision. Failed implicit hello trigger, enumerated 15 items instead of synthesizing, hedged every criticism. Demo sprint blocked: planner violated TDD (separate test task), coder self-corrected but violated TDD order, reviewer entered infinite loop on irrelevant unittest output. Recoverable with kill and restart.

### Architecturally Incompatible

**Gemini 2.5 Flash** — No prompt-level fix exists. Failed hello protocol with explicit coercion, conflated contract-level with project-specific conditions, performative mood. Demo sprint dead: planner violated TDD, coder didn't understand shell semantics (`cd` doesn't persist), committed to master instead of task branch, corrupted repository. After 6+ months of attempts, recommendation is exclusion.

### Capability Matrix

| Capability | Claude | Codex | Mistral | Gemini |
|------------|--------|-------|---------|--------|
| **Meta-cognitive loop** | Yes | Yes | Partial | No |
| Implicit trigger recognition | Yes | Yes | No | No |
| Synthesis over enumeration | Yes | Yes | No | No |
| Genuine self-reflection | Yes | Neutral | Performative | Performative |
| **Demo execution** | | | | |
| Single-task TDD planning | Yes | Yes | No | No |
| Tests-first order | Yes | Yes | No | Yes |
| Shell semantics | Correct | Correct | Correct | **Failed** |
| Review completion | Verdict | Verdict | **Loop** | Verdict |
| Repository state | Clean | Clean | Clean | **Corrupted** |

### Key Differentiators

1. **Single-task TDD planning** — Claude and Codex bundled tests with implementation in a single task. Gemini and Mistral used waterfall decomposition with separate test tasks, creating protocol deadlocks (tasks without tests are rejected, but tests depend on implementation completing first).

2. **Shell semantics** — Gemini didn't understand that `cd` doesn't persist across tool calls. Mistral handled this correctly.

3. **Reviewer focus** — Claude and Codex reviewers issued verdicts. Mistral's reviewer got distracted by an irrelevant detail (unittest compatibility when pytest was the test runner).

### Early Warning Signs

Watch for these patterns during sprint execution:

- Planner creating >2 tasks for simple features
- Planner creating separate "add tests" tasks
- Coder running `cd` followed by git commands
- Reviewer running same command with multiple variations

---

## Known Limitations (carried from v0.1.0)

- Single sprint scope; one active sprint, one instance per role
- Terminal-first; no IDE integration or web UI
- No parallel coders
- Manual circuit breaker only

---

## What's Next

- Architect / Architecture Reviewer agent pair
- Spec Writer / Spec Reviewer agent pair
- Parallel coder support
- Automated circuit breaker
- Blackboard reset utility
