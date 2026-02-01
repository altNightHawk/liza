# 4 - Dual-Mode Contract Architecture (Pairing vs Multi-Agent)

## Context and Problem Statement

The monolithic pairing contract (v3) was designed for human-in-loop collaboration. With the blackboard coordination in place (ADR-0003), the multi-agent system needed different approval semantics:

- **Approval gates** needed to write to the blackboard, not wait for human input
- **Some contract sections** (collaboration modes, retrospectives, magic phrases) were irrelevant in MAS context
- **Core invariants** (Tier 0-1 rules, security, recovery) applied universally

The question: how to support both modes without maintaining two divergent contracts?

## Considered Options

1. **Maintain two separate contracts** — One for pairing, one for MAS
2. **Runtime parameterization** — Single contract with conditional sections
3. **Layered architecture** — CORE.md + mode-specific extensions

## Decision Outcome

Chose **Option 3**: Split into CORE.md (70% shared) + PAIRING_MODE.md + MULTI_AGENT_MODE.md with auto-detection.

### Rationale

**Keep what works together.** The Tier 0 invariants, Golden Rules, security protocol, and recovery mechanisms are battle-tested. Duplicating them creates drift risk. CORE.md holds everything that isn't absolutely specific to human interaction.

**Mode is fixed for session.** No switching mid-conversation. Cross-mode operations are forbidden:
- A Pairing session cannot interact with the blackboard
- A Liza session cannot use magic phrases or human approval gates

This prevents the failure mode of "patching a complex system" — mixing approval semantics leads to confused agents and audit trail gaps.

**Auto-detect for convenience.** Mode selection happens automatically from bootstrap context:
- First prompt contains "You are a Liza ... agent" → Multi-Agent mode
- Otherwise → Pairing mode (default)

Explicit mode selection would be boring for users and error-prone for scripts.

### Architecture

```
CLAUDE.md (symlink to ~/.liza/CORE.md)
    │
    ▼
CORE.md (entry point + universal rules)
    │
    └── Mode Selection Gate (auto-detect from bootstrap)
        │
        ├── Default (no Liza agent) → Read PAIRING_MODE.md
        │                              → Human approval gates
        │                              → Magic phrases enabled
        │
        └── "You are a Liza ... agent" → Read MULTI_AGENT_MODE.md
                                       → Blackboard checkpoints
                                       → Peer approval
```

**What lives where:**

| Component | Location | Rationale |
|-----------|----------|-----------|
| Tier 0-3 rules | CORE.md | Universal invariants |
| Golden Rules 1-14 | CORE.md | Behavioral foundation |
| Security Protocol | CORE.md | Never mode-specific |
| Recovery Protocols | CORE.md | Same recovery regardless of mode |
| Session Initialization | Mode-specific | Different greeting/setup |
| Approval semantics | Mode-specific | Human vs blackboard |
| Collaboration modes | PAIRING_MODE.md | Irrelevant in MAS |
| Role definitions | MULTI_AGENT_MODE.md | Coder/Reviewer/Planner |

### Consequences

**Positive:**
- Single source of truth for core rules — fix once, applies everywhere
- Mode-specific behavior is explicit and auditable
- Pairing users get the same contract they've used for months
- MAS agents get streamlined rules without human-interaction cruft

**Limitations accepted:**
- Agents must read two files (CORE + mode) on initialization
- Some redundancy in explaining concepts across files
- The 70/30 split may shift as both modes evolve

---
*Reconstructed from commits 200e4df, c3f277d (2026-01-20)*
