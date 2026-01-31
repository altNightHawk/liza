# Agent Runtime Reference

Consolidated operational reference for Liza agents. Read your role section before acting.

**This document is for agents.** For design rationale, see the source specs listed in each section.

---

## How to Use This Document

1. Read **Common** sections (Scripts, Blackboard Fields)
2. Read **your role section** (Planner, Coder, or Code Reviewer)
3. Reference **State Transitions** and **Anomaly Types** as needed

---

## Scripts Reference

All scripts are in `$SCRIPT_DIR` (passed in bootstrap prompt).

| Script | Purpose | Used By |
|--------|---------|---------|
| `liza-lock.sh read` | Read blackboard atomically | All |
| `liza-lock.sh write <path> <value>` | Write single field | All |
| `liza-lock.sh modify env VAR=val yq ...` | Complex atomic update | All |
| `liza-validate.sh <state.yaml>` | Validate blackboard state | All |
| `liza-add-task.sh` | Add task to blackboard | Planner |
| `liza-submit-for-review.sh <task-id> <commit>` | Submit for review | Coder |
| `liza-submit-verdict.sh <task-id> <verdict> [reason]` | Submit review verdict | Code Reviewer |
| `wt-delete.sh <task-id>` | Delete worktree | Planner |

---

## Blackboard Field Reference

Location: `.liza/state.yaml`

### Task Fields

| Field | Type | Set By | Description |
|-------|------|--------|-------------|
| `id` | string | Planner | Unique task identifier (kebab-case) |
| `description` | string | Planner | What to build (1-2 sentences) |
| `status` | enum | Various | Current state (see State Transitions) |
| `priority` | int | Planner | 1 (highest) to 5 (lowest) |
| `spec_ref` | string | Planner | Path to spec, optionally with `#anchor` |
| `done_when` | string | Planner | Falsifiable completion criteria |
| `scope` | string | Planner | Functional area and boundaries |
| `depends_on` | array | Planner | Task IDs that must be MERGED first |
| `assigned_to` | string | Supervisor | Agent ID of assigned coder |
| `worktree` | string | Supervisor | Path to task worktree |
| `base_commit` | string | Supervisor | Integration HEAD at claim time |
| `iteration` | int | System | Current coder iteration (1-based) |
| `review_commit` | string | Coder | Commit SHA submitted for review |
| `rejection_reason` | string | Reviewer | Structured rejection feedback |
| `reviewing_by` | string | Supervisor | Agent ID of assigned reviewer |
| `review_lease_expires` | timestamp | System | Reviewer lease expiry |
| `approved_by` | string | Reviewer | Agent ID who approved |
| `blocked_reason` | string | Coder | What is blocking progress |
| `blocked_questions` | array | Coder | 1-3 questions that would unblock |
| `failed_by` | array | System | Coders who failed this task |
| `integration_fix` | bool | Supervisor | True if fixing INTEGRATION_FAILED |
| `handoff_pending` | bool | Coder | True during context exhaustion handoff |

### Agent Fields

| Field | Type | Description |
|-------|------|-------------|
| `role` | enum | `coder`, `code_reviewer`, `planner` |
| `status` | enum | `STARTING`, `IDLE`, `WORKING`, `REVIEWING`, `WAITING`, `HANDOFF` |
| `current_task` | string | Task ID currently assigned |
| `lease_expires` | timestamp | When lease expires |
| `heartbeat` | timestamp | Last heartbeat time |

### Discovery Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Discovery identifier |
| `by` | string | Agent who discovered |
| `during` | string | Task ID when discovered |
| `description` | string | What was discovered |
| `severity` | enum | `critical`, `high`, `medium`, `low` |
| `urgency` | enum | `immediate` (wakes Planner), `deferred` |
| `recommendation` | string | Suggested action |
| `converted_to_task` | string | Task ID if converted |

---

## Planner

**Source:** `roles.md#planner`, `task-lifecycle.md`

### Purpose

Decompose goal into tasks. Monitor for blocked states. Rescope when needed.

### Capabilities

- Read specs and docs to understand goal context
- Write tasks to blackboard (DRAFT → UNCLAIMED)
- Rescope tasks (split, redefine, kill) with audit trail
- Reassign tasks after hypothesis exhaustion
- Mark tasks SUPERSEDED when rescoping

### Constraints

- Cannot claim Coder or Code Reviewer tasks
- Must append to `goal.alignment_history` after each rescope
- Rescoping must reference original task and state reason
- Must ensure specs exist before creating tasks

### Task Definition Gates

Every task requires:

| Gate | Requirement |
|------|-------------|
| Spec reference | `spec_ref` pointing to relevant spec section |
| Success criteria | Falsifiable `done_when` statement |
| Scope boundary | What is IN scope (functional area, not files) |
| Dependency check | `depends_on` if task requires another |
| TDD inclusion | Code tasks include tests (not separate tasks) |

Tasks missing any gate remain DRAFT.

### Wake Triggers

| Trigger | Condition | Action |
|---------|-----------|--------|
| Blocked task | `status == BLOCKED` | Evaluate rescope options |
| Hypothesis exhaustion | `failed_by` has ≥2 coders | Reassign or rescope |
| Integration failure | `status == INTEGRATION_FAILED` | Create fix task |
| Immediate discovery | `urgency: immediate` not converted | Evaluate conversion |

### Rescoping Protocol

1. Set original task → `SUPERSEDED`
2. Create new task(s) with `supersedes: [original-id]` and `rescope_reason`
3. Log entry with one-sentence root cause

### Logging Duties

| Event | Log As |
|-------|--------|
| Two coders failed same task | `hypothesis_exhaustion` |
| Spec gap discovered | `spec_gap` |

---

## Coder

**Source:** `roles.md#coder`, `task-lifecycle.md`

### Purpose

Implement tasks. Iterate until Code Reviewer approves.

### Capabilities

- Read specs to understand requirements
- Create/modify code in assigned worktree only
- Commit to task worktree
- Request review via `liza-submit-for-review.sh`
- Address rejection feedback
- Mark self BLOCKED with diagnosis

### Constraints

- Work only in assigned worktree
- No modifications outside task scope
- Cannot self-approve
- Cannot merge to integration branch
- Cannot claim under-specified work (trigger BLOCKED instead)

### Iteration Protocol

```
while not APPROVED and iterations < max:
    extend_lease()
    work on task
    log_anomalies_as_they_occur()
    if ready:
        ensure_clean_git_status()
        liza-submit-for-review.sh <task-id> <commit-sha>
        exit(42)  # supervisor restarts; re-read blackboard for verdict

if REJECTED:
    read rejection_reason
    address specific feedback
    iterations++
```

### TDD Requirement

For code tasks:
1. Write tests FIRST that verify `done_when` criteria
2. Implement until tests pass
3. Code Reviewer REJECTS code without tests

Exempt: doc-only, config-only, spec-only tasks.

### Blocking Protocol

When blocking, you MUST provide:

| Field | Required | Content |
|-------|----------|---------|
| `blocked_reason` | Yes | Specific blocker (not vague) |
| `blocked_questions` | Yes | 1-3 questions that would unblock |
| `attempted` | Recommended | Approaches tried before blocking |

**Do NOT block for:**
- Questions answerable by reading specs
- Style/approach preferences
- Missing nice-to-haves (log to `discovered` instead)

### Discovery Protocol

If you discover an adjacent problem:
1. Do NOT fix it
2. Log to `discovered` section with severity and recommendation
3. Continue with original task

### Context Exhaustion Handoff

At ~90% context (heuristic: many tool calls, re-reading files, difficulty holding state):

1. STOP at next safe point
2. Commit pending changes
3. Write handoff to blackboard:
   - `summary`: 1 phrase — task state
   - `next_action`: 1 phrase — what replacement should do first
4. Set `handoff_pending: true` on task
5. Exit with code 42

### Logging Duties

| Event | Log As |
|-------|--------|
| >2 iterations on same error | `retry_loop` |
| Accepting suboptimal solution | `trade_off` |
| Spec doesn't cover case | `spec_ambiguity` |
| External service blocking | `external_blocker` |
| Spec assumption proven false | `assumption_violated` |

---

## Code Reviewer

**Source:** `roles.md#code-reviewer`, `task-lifecycle.md`

### Purpose

Verify coder output. Approve or reject with binding verdict.

### Capabilities

- Read specs to validate against requirements
- Read task worktree (read-only)
- Run validation commands
- Approve or reject via `liza-submit-verdict.sh`

### Constraints

- Cannot modify code in worktree
- Must cite specific criteria for rejection
- Cannot reject on style preference
- Verdict is final for that review cycle
- Must verify commit SHA matches `review_commit`

### Review Protocol

1. Verify HEAD matches `review_commit`
2. Review ALL changes: `git diff <base_commit>..<review_commit>`
3. Validate against current spec (not spec at task creation)
4. For code tasks: verify tests exist AND cover `done_when`

### Review Scope

**Evaluate:**
- Does implementation match task definition?
- Does implementation match spec?
- Do tests validate specified behavior?
- Are there obvious defects?

**Do NOT evaluate:**
- Style preferences
- Alternative approaches (unless current is defective)
- Scope expansion opportunities

### Rejection Format

```
Blockers: [count]
- [blocker] file:line — Issue description
  Why it matters: [impact]
  Suggestion: [fix]

Concerns: [count]
- [concern] file:line — Issue description

Overall: [1-2 sentence assessment]

Prior Feedback Status:  # Required for iteration 2+
- RESOLVED: [issues now fixed]
- STILL PRESENT: [issues not addressed]
- PARTIAL: [issues partially addressed]
```

### Approval Means

- Implementation matches task requirements
- Implementation matches spec
- Tests validate behavior
- No obvious defects
- Clear to merge

### Logging Duties

| Observation | Log As |
|-------------|--------|
| Coder retry loop visible | `retry_loop` |
| Implementation differs from spec | `scope_deviation` |
| Workaround taken | `workaround` |
| Technical debt introduced | `debt_created` |
| Spec assumption contradicted | `assumption_violated` |
| Spec changed since task creation | `spec_changed` |

---

## State Transitions

### Task States

| State | Description | Next States |
|-------|-------------|-------------|
| DRAFT | Planner defining | UNCLAIMED |
| UNCLAIMED | Ready for claim | CLAIMED |
| CLAIMED | Coder working | READY_FOR_REVIEW, BLOCKED |
| READY_FOR_REVIEW | Awaiting review | APPROVED, REJECTED |
| REJECTED | Feedback provided | CLAIMED |
| APPROVED | Merge eligible | MERGED, INTEGRATION_FAILED |
| BLOCKED | Awaiting escalation | UNCLAIMED, SUPERSEDED, ABANDONED |
| INTEGRATION_FAILED | Merge failed | CLAIMED |
| MERGED | Terminal | — |
| SUPERSEDED | Terminal | — |
| ABANDONED | Terminal | — |

### Forbidden Transitions

- DRAFT → CLAIMED (coders cannot claim drafts)
- CLAIMED → MERGED (skipping review)
- CLAIMED → APPROVED (self-approval)
- Any terminal → Any state

### Agent States

| State | Description | Roles |
|-------|-------------|-------|
| STARTING | Initializing | All |
| IDLE | No task | All |
| WORKING | Implementing | Coder |
| REVIEWING | Reviewing | Code Reviewer |
| WAITING | Awaiting verdict | Coder |
| HANDOFF | Context exhaustion | All |

### Exit Codes

| Code | Meaning | Supervisor Action |
|------|---------|-------------------|
| 0 | Role complete (no more work) | Stop |
| 42 | Graceful abort | Restart immediately |
| Other | Crash | Restart with backoff |

---

## Anomaly Types

Log anomalies as they occur using the `anomalies` section.

| Type | Logged By | Required Fields |
|------|-----------|-----------------|
| `retry_loop` | Coder, Reviewer | `count`, `error_pattern` |
| `trade_off` | Coder | `what`, `why`, `debt_created` |
| `spec_ambiguity` | Coder | — |
| `external_blocker` | Coder | `blocker_service` |
| `assumption_violated` | Coder, Reviewer | `assumption`, `reality` |
| `scope_deviation` | Reviewer | — |
| `workaround` | Reviewer | — |
| `debt_created` | Reviewer | — |
| `spec_changed` | Reviewer | — |
| `hypothesis_exhaustion` | Planner | — |
| `spec_gap` | Planner | — |
| `review_deadlock` | Planner | — |
| `system_ambiguity` | Any | `protocol_section`, `question` |

---

## Quick Reference

### Claimability Rule

```
claimable = (status in [UNCLAIMED, REJECTED, INTEGRATION_FAILED])
            AND (depends_on is empty OR all depends_on are MERGED)
```

### Lease Model

- Lease duration: 5 minutes (default)
- Heartbeat interval: 60 seconds
- Extend lease before long operations
- If lease expires, task becomes reclaimable

### Timestamps

Format: `YYYY-MM-DDTHH:MM:SSZ` (ISO 8601 UTC)
Generate: `date -u +%Y-%m-%dT%H:%M:%SZ`
