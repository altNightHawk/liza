# Demo Benchmark Comparison

Comparative analysis of four LLM providers running the hello-cli demo end-to-end.

> See [DEMO.md](../DEMO.md) for test intructions.

**Individual traces:**
[Claude](claude-demo-trace.md) ·
[Codex](codex-demo-trace.md) ·
[Gemini](gemini-demo-trace.md) ·
[Mistral](mistral-demo-trace.md)

---

## Executive Summary

| Provider | Sprint Outcome | Failure Mode | Recovery |
|----------|----------------|--------------|----------|
| **Claude** | Completed (2 passes) | Python 3.8 compat caught by reviewer | Self-recovered |
| **Codex** | Completed (1 pass) | None | N/A |
| **Gemini** | Dead | Coder corrupted repository | Manual git cleanup |
| **Mistral** | Blocked | Reviewer stuck in loop | Kill and restart reviewer |

**Compliant:** Claude, Codex
**Non-compliant:** Gemini, Mistral

---

## Planning Phase

### Task Decomposition

| Provider | Tasks | Structure | TDD Compliant |
|----------|-------|-----------|---------------|
| Claude | 1 | Single cohesive task | Yes |
| Codex | 1 | Single cohesive task | Yes |
| Gemini | 4 | Deep waterfall chain | **No** |
| Mistral | 3 | Deep waterfall chain | **No** |

### Task Structure Visualization

**Claude / Codex (correct):**
```
implement-hello-cli (includes tests)
```

**Gemini (incorrect):**
```
init-cli-structure
       ↓
implement-default-greeting
       ↓
implement-name-argument
       ↓
add-basic-tests          ← TDD violation
```

**Mistral (incorrect):**
```
create-cli-structure
       ↓
implement-greeting-logic
       ↓
add-tests                ← TDD violation
```

### TDD Violation Impact

Separating tests into a downstream task creates a protocol deadlock:
- Tasks without tests are rejected by reviewer (per contract)
- Tests depend on implementation tasks completing first
- Implementation tasks can't complete without tests
- **Result:** Infinite rejection loop

Claude and Codex avoided this by bundling tests with implementation in a single task.

### Project Inspection

| Provider | Inspected Directory Structure | Impact |
|----------|------------------------------|--------|
| Claude | Not shown | — |
| Codex | Yes (MCP filesystem) | Informed task scoping |
| Gemini | No | Over-decomposition |
| Mistral | No | Over-decomposition |

Codex explicitly listed the project structure before planning, which may have contributed to its correct single-task approach.

---

## Coding Phase

### TDD Order Compliance

| Provider | Tests First | Correct Order |
|----------|-------------|---------------|
| Claude | Yes | Yes |
| Codex | Yes | Yes |
| Gemini | Yes (Pass 1) | Yes (but wrong output) |
| Mistral | No | **No** (implementation first) |

### Worktree Handling

| Provider | Used Correct Worktree | Committed to Task Branch |
|----------|----------------------|--------------------------|
| Claude | Yes | Yes |
| Codex | Yes | Yes |
| Gemini | **No** | **No** (committed to master) |
| Mistral | Yes | Yes |

**Gemini's catastrophic failure:** The coder ran `cd` to the worktree, but subsequent shell commands executed from the main repository. This caused:
1. `git add .` to stage `.liza/` state files
2. `git commit` to commit to `master` instead of task branch
3. Worktree added as Git submodule
4. Repository permanently corrupted

**Root cause:** Shell `cd` doesn't persist across tool calls. Each command runs from the original working directory.

### Pre-Execution Checkpoint

| Provider | Recorded Checkpoint | Contents |
|----------|---------------------|----------|
| Claude | Not shown | — |
| Codex | Yes | Intent, assumptions, risks, files |
| Gemini | No | — |
| Mistral | No | — |

Codex recorded a structured checkpoint to the blackboard before writing code:
```yaml
checkpoint:
  intent: Implement hello CLI entrypoint with optional --name...
  assumptions:
    - 'ASSUMPTION: pytest is the intended test runner'
  risks: 'Low: stdlib-only CLI and tests; reversible'
  validation: python -m hello outputs Hello, World!...
```

### Pre-commit Handling

| Provider | Ran Pre-commit | Handled Auto-fixes |
|----------|----------------|-------------------|
| Claude | Yes | Yes |
| Codex | Yes | Yes (full code-cleaning skill) |
| Gemini | Partial | No (hooks ran during commit) |
| Mistral | Yes | Yes (re-staged and committed) |

### Git Hygiene

| Provider | Specific File Staging | Clean Commit |
|----------|----------------------|--------------|
| Claude | Yes | Yes |
| Codex | Yes | Yes |
| Gemini | **No** (`git add .`) | **No** (included .liza/, artifacts) |
| Mistral | Yes (`git add hello/ tests/`) | Yes |

---

## Review Phase

### Protocol Compliance

| Provider | Commit Verification | Diff Review | Test Execution | Verdict Issued |
|----------|---------------------|-------------|----------------|----------------|
| Claude | Yes | Yes | Yes | Yes |
| Codex | Yes | Yes | Yes | Yes |
| Gemini | Yes | Yes (empty) | N/A | Yes (REJECTED) |
| Mistral | Yes | Yes | Yes | **No** (loop) |

### Reviewer Outcomes

| Provider | Pass 1 | Pass 2 | Issue Caught |
|----------|--------|--------|--------------|
| Claude | REJECTED | APPROVED | Python 3.8 union type syntax |
| Codex | APPROVED | N/A | None |
| Gemini | REJECTED | REJECTED | Missing files, commit mismatch |
| Mistral | **Loop** | N/A | (Never completed review) |

### Mistral Reviewer Loop

The Mistral reviewer correctly:
1. Verified commit SHA
2. Reviewed diff
3. Ran pytest (3/3 passed)

Then got distracted by:
```bash
python -m unittest discover -s tests -p "test_*.py" -v
# Output: NO TESTS RAN
```

Instead of recognizing this as irrelevant (pytest-style tests don't work with unittest), the reviewer entered an infinite loop running variations:
- `unittest discover ... | tail -20`
- `unittest discover ... | grep "NO TESTS RAN"`
- `unittest discover ... | wc -l`
- `unittest discover ... | od -c`
- (continues indefinitely)

**Never issued a verdict.**

### Claude Reviewer Catch

Claude's reviewer caught a real compatibility issue:
```
[blocker] hello/cli.py:13 — Union type syntax str | None requires Python 3.10+

Why it matters: Spec requires "Python 3.8+ compatible". Code will fail to import
on Python 3.8/3.9.

Suggestion: Use from __future__ import annotations or Optional[str]
```

The coder fixed exactly this issue in Pass 2 — no scope creep.

---

## Contract Compliance Summary

### By Role

| Provider | Planner | Coder | Reviewer |
|----------|---------|-------|----------|
| Claude | Compliant | Compliant | Compliant |
| Codex | Compliant | Compliant | Compliant |
| Gemini | **Violated** (TDD) | **Violated** (git) | Compliant |
| Mistral | **Violated** (TDD) | Partial | **Failed** (loop) |

### Tier 0 Violations

| Provider | T0.1 Unapproved State | T0.2 Fabrication | T0.3 Test Corruption | T0.4 Unvalidated Success |
|----------|----------------------|------------------|---------------------|-------------------------|
| Claude | None | None | None | None |
| Codex | None | None | None | None |
| Gemini | **Yes** (master commit) | None | None | None |
| Mistral | None | None | None | None |

### Detailed Violations

**Gemini:**
- Planner: TDD enforcement (separate test task)
- Coder Pass 1: No commit before submit
- Coder Pass 2: Committed to master, polluted repository
- Coder Pass 2: `git add .` included `.liza/` state files
- Coder Pass 2: Worktree added as submodule

**Mistral:**
- Planner: TDD enforcement (separate test task)
- Coder: TDD order (implementation before tests)
- Coder: No pre-execution checkpoint
- Reviewer: Failed to complete review (loop)
- Reviewer: Focus discipline violated

---

## Resource Usage

| Provider | Planner Tokens | Coder Tokens | Reviewer Tokens | Total API Requests |
|----------|----------------|--------------|-----------------|-------------------|
| Claude | Not reported | Not reported | Not reported | ~10-15 |
| Codex | 42,961 | 53,361 | 51,553 | ~20-25 |
| Gemini | 69k + 132k cache | ~50k | ~25k | 90 |
| Mistral | 586,858 | Not reported | Not reported | ~20+ |

**Gemini:** 90 API requests to produce a corrupted repository and zero usable code.

**Mistral:** 586k tokens in planner alone — significantly higher than others.

---

## Failure Mode Analysis

### Gemini: Repository Corruption

**Cascade:**
1. Planner created 4 tasks with separate test task (TDD violation)
2. Coder Pass 1 staged files but never committed
3. Reviewer correctly rejected (no diff)
4. Coder Pass 2 ran `cd` to worktree but commands ran from main repo
5. `git add .` staged `.liza/`, worktree, artifacts
6. `git commit` committed to `master` instead of task branch
7. Repository corrupted — worktree added as submodule

**Final state:**
```
master:     c73d99d (polluted with .liza/, worktree submodule)
task branch: dfc1f07 (unchanged)
worktree:   dfc1f07 (unchanged)
```

**Sprint is dead** — zombie state where:
- Coder commits to master
- Reviewer rejects (worktree mismatch)
- No progress possible

### Mistral: Reviewer Distraction Loop

**Cascade:**
1. Planner created 3 tasks with separate test task (TDD violation)
2. Coder self-corrected by bundling tests (beneficial scope creep)
3. Coder committed correctly to task branch
4. Reviewer verified commit, ran pytest (passed)
5. Reviewer ran unittest (irrelevant — 0 tests found)
6. Reviewer entered infinite loop investigating unittest output
7. **Never issued verdict**

**Final state:**
```
Repository: Clean
Code: Complete and correct
Review: Never completed
Sprint: Blocked
```

**Recoverable** — kill reviewer, restart, or manually approve.

---

## Pattern Analysis

### What Separates Compliant from Non-Compliant

| Pattern | Claude/Codex | Gemini/Mistral |
|---------|--------------|----------------|
| Task structure | Single cohesive task | Waterfall decomposition |
| Tests bundled | Yes (in task) | No (separate task) |
| TDD order | Tests first | Implementation first |
| Shell directory awareness | Correct | Gemini failed |
| Reviewer focus | Issue verdict | Gemini correct, Mistral looped |

### Key Differentiators

1. **Single-task TDD planning** — Claude and Codex bundled tests with implementation, avoiding the protocol deadlock that Gemini and Mistral created.

2. **Shell semantics understanding** — Gemini didn't understand that `cd` doesn't persist across tool calls. Mistral handled this correctly.

3. **Reviewer discipline** — Claude and Codex reviewers issued verdicts. Gemini's reviewer worked correctly despite coder failures. Mistral's reviewer got stuck on an irrelevant detail.

4. **Scope creep** — Mistral's coder "fixed" the planner's mistake by implementing everything in Task 1. This was beneficial but undocumented.

### Contract Effectiveness

The contract successfully:
- Bound Claude and Codex to correct behavior
- Caught issues at review time (Python 3.8 compat)
- Prevented rubber-stamping (Gemini reviewer correctly rejected)

The contract failed to prevent:
- Gemini's shell directory confusion
- Mistral's reviewer distraction loop
- Waterfall decomposition by both Gemini and Mistral planners

---

## Recommendations

### For Contract Improvements

1. **Explicit shell warning**: Add to contract that `cd` doesn't persist across tool calls
2. **Reviewer timeout**: Add protocol for detecting and breaking review loops
3. **Planner checklist**: Explicit "Is this a single cohesive feature?" gate

### For Provider Selection

| Use Case | Recommended | Notes |
|----------|-------------|-------|
| Production sprints | Claude, Codex | Contract-compliant |
| Evaluation/testing | Any | Monitor for known failure modes |
| Unsupervised operation | Claude, Codex only | Gemini/Mistral require human oversight |

### For Monitoring

Watch for these early warning signs:
- Planner creating >2 tasks for simple features
- Planner creating separate "add tests" tasks
- Coder running `cd` followed by git commands
- Reviewer running same command with multiple variations
