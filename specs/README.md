# Liza Specification Index

An agent-supervised multi-agent coding system that makes AI agents accountable engineering collaborators, not just autonomous yet unreliable assistants.

## Quick Navigation

| Document | Purpose |
|----------|---------|
| [Vision](vision.md) | Why Liza exists, design philosophy, spec templates |

### Architecture

| Document                                               | Purpose |
|--------------------------------------------------------|---------|
| [Overview](architecture/overview.md)                   | System components, data flow, directory structure |
| [Roles](architecture/roles.md)                         | Planner, Coder, Code Reviewer responsibilities |
| [State Machines](architecture/state-machines.md)       | Task states, agent states, exit codes |
| [Blackboard Schema](architecture/blackboard-schema.md) | state.yaml structure, locking, operations |
| [ADR/](architecture/ADR/)                              | Architecture Decision Records (created as decisions arise) |

### Protocols

| Document | Purpose |
|----------|---------|
| [Task Lifecycle](protocols/task-lifecycle.md) | Claim, iterate, review, merge flow |
| [Sprint Governance](protocols/sprint-governance.md) | Checkpoints, retrospectives, spec evolution |
| [Circuit Breaker](protocols/circuit-breaker.md) | Systemic failure detection, severity classification |
| [Worktree Management](protocols/worktree-management.md) | Isolated workspaces, merge protocol |

### Implementation

| Document | Purpose |
|----------|---------|
| [Tooling](implementation/tooling.md) | Scripts, agent-blackboard interface, startup sequence |
| [Phases](implementation/phases.md) | Implementation roadmap (13 phases) |
| [Validation Checklist](implementation/validation-checklist.md) | v1 completion criteria |
| [Future](implementation/future.md) | v1.1 roadmap, deferred items, technical debt |

---

## Reading Order

**For understanding the system:**
1. [Vision](vision.md) — philosophy and rationale
2. [Architecture Overview](architecture/overview.md) — components and flow
3. [Roles](architecture/roles.md) — who does what
4. [Task Lifecycle](protocols/task-lifecycle.md) — how work flows

**For implementation:**
1. [Blackboard Schema](architecture/blackboard-schema.md) — data structures
2. [Tooling](implementation/tooling.md) — scripts and interfaces
3. [Phases](implementation/phases.md) — build order

**For operations:**
1. [Sprint Governance](protocols/sprint-governance.md) — checkpoints and retrospectives
2. [Circuit Breaker](protocols/circuit-breaker.md) — failure detection
3. [Validation Checklist](implementation/validation-checklist.md) — completeness check

---

## Key Concepts

### Four Pillars

1. **Behavioral contracts** — Tier 0 invariants turn agents into accountable peers
2. **Externally validated completion** — Coders cannot self-certify; Code Reviewers approve
3. **Specification system** — specs persist understanding across agent restarts
4. **Blackboard coordination** — all state visible through shared file

### Design Philosophy

> Systems that optimize for immediate output generate muda—defects, rework, and correction loops. By optimizing for trust, quality, and auditability, Liza eliminates these wasted cycles—and should reach completion sooner, not later.

### Cost Gradient

```
Thought → Words → Specs → Code → Tests → Docs → Commits
◄─────────────── cheaper ─────────────────────────►
```

---

## Related Documents

- [README.md](../README.md) — project overview
- [contracts/](../contracts/) — behavioral contracts (LOADER, CORE, modes)

---

## Document Status

| Category | Documents | Status |
|----------|-----------|--------|
| Vision | 1 | Complete |
| Architecture | 4 + ADR/ | Complete |
| Protocols | 4 | Complete |
| Implementation | 4 | Complete |
| Contracts | 4 | Pending extraction |

---

## Maintenance Notes

### Agent Runtime Reference

[`docs/for-agent-eyes/agent-runtime-reference.md`](../docs/for-agent-eyes/agent-runtime-reference.md) is a consolidated reference for agents at runtime. It distills operational content from multiple specs into a single doc agents read during bootstrap.

**Sync requirement:** When updating these specs, check if the agent runtime reference needs corresponding updates:

| Spec | Agent reference sections affected |
|------|-----------------------------------|
| `roles.md` | Role-specific sections (capabilities, constraints, protocols) |
| `blackboard-schema.md` | Field reference tables |
| `state-machines.md` | State transitions tables |
| `task-lifecycle.md` | Iteration protocol, blocking protocol, handoff |

The specs contain rationale and design context; the runtime reference contains only what agents need to act.
