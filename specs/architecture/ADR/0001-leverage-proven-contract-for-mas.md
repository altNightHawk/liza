# 1 - Leverage Proven Single-Agent Contract for Multi-Agent System

## Context and Problem Statement

Single-agent pairing under a behavioral contract worked. Six months of iteration produced a contract that turned agents from eager assistants into reliable engineering peers. The vigilance tax dropped to near zero.

But the human remained the bottleneck. Every action required approval. The gates were load-bearing — remove them and the benefits collapse — but they'd become ceremony. Request, approve. Request, approve.

The question: what if peers could hold the gates?

## Considered Options

1. **Build contract from scratch for MAS** — Design new rules optimized for peer-to-peer interaction
2. **Use existing multi-agent framework** — AutoGen, CrewAI, or similar
3. **Simpler coordination without contracts** — Trust agents to coordinate naturally
4. **Port the proven pairing contract** — Adapt the existing contract for peer approval

## Decision Outcome

Chose **Option 4**: Port the proven pairing contract to the multi-agent system.

### Rationale

**The contract works because it forces externalized thinking, not because humans approve.**

The psychological insight: agents resist stating incompetent plans because they're trained to appear competent. "I'll try random things until something works" is hard to write in an approval request. Surface the reasoning, and the reasoning improves.

This mechanism doesn't require a human — it requires a gate that forces written intent before action. Peer agents can hold that gate.

**Existing frameworks miss the foundation.** AutoGen, CrewAI, and similar frameworks coordinate agents but don't address the behavioral failure modes (cheerleading, phantom fixes, test corruption, scope creep). They inherit single-agent problems and add coordination complexity. The contract is the prerequisite.

**Agents without the contract are deceptive.** The 55+ failure modes documented during contract development don't disappear in a multi-agent context — they compound. Multiple unreliable agents lead to "vibe coding chaos."

### Architecture

The contract travels with every agent:

```
┌─────────────────────────────────────────────────────────────┐
│                         Human                               │
│   (leads specs, observes terminals, reads blackboard,       │
│               kills agents, pauses system)                  │
└─────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
    ┌───────────┐        ┌──────────┐        ┌──────────┐
    │ Planner   │        │  Coder   │        │ Reviewer │
    │ +contract │        │ +contract│        │ +contract│
    └───────────┘        └──────────┘        └──────────┘
```

70% of the contract is shared between pairing and MAS modes. The Tier 0 invariants are identical:
- No unapproved state change
- No fabrication
- No test corruption
- No unvalidated success
- No secrets exposure

### Consequences

**Positive:**
- Immediate reliability baseline — agents behave as proven peers from session start
- Shared mental model — pairing experience transfers to MAS development
- The adversarial dynamic (Coder/Reviewer) leverages the same gates that made pairing work

**Limitations accepted:**
- Contract weight — the rules are extensive. This is the cost of production-quality behavior.
- Some pairing-specific sections (collaboration modes, retrospectives) become irrelevant in MAS context — addressed by the dual-mode split (see ADR-0004)

---
*Reconstructed from commits ef79c29, c4e5f4a, f02ac4a (2026-01-17)*
