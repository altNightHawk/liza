# 8 - Multi-LLM Provider Support

## Context and Problem Statement

Liza was built with Claude as the primary LLM. However, being locked to a single provider creates risk:
- Provider outages affect all work
- Cost optimization requires alternatives
- Different models may excel at different tasks

Should Liza support multiple LLM providers?

## Considered Options

1. **Claude-only** — Optimize for one provider, accept lock-in
2. **Abstraction layer** — Generic interface, provider-specific adapters
3. **Direct integration** — Add provider support case-by-case in scripts

## Decision Outcome

Chose **Option 3**: Direct integration of additional providers (Codex, Mistral, Gemini) in the agent script.

### Rationale

**LLM-agnostic in principle.** The behavioral contract is not Claude-specific. The rules, gates, and invariants apply to any agent capable of following instructions.

**Practical for POC.** Adding a provider means extending `liza-agent.sh` with provider-specific invocation logic. No abstraction layer needed yet.

**Reality check on compliance.** Testing revealed that not all providers can fully comply with the contract:
- **Claude** and **Codex**: Full compliance achievable
- **Gemini** and **Mistral**: Cannot be made to comply strictly with instructions

This is documented as a warning, not a blocker — users can experiment but should prefer compliant providers for production work.

### Architecture

```bash
# In liza-agent.sh
case "$PROVIDER" in
  claude)
    claude --print "$PROMPT" ...
    ;;
  codex)
    codex --prompt "$PROMPT" ...
    ;;
  gemini)
    # Gemini-specific invocation
    ;;
  mistral)
    # Mistral-specific invocation
    ;;
esac
```

**Provider configuration:**
- `LIZA_PROVIDER` environment variable selects provider
- Provider-specific settings (API keys, endpoints) from environment
- Contract activation docs include setup for each provider

### Consequences

**Positive:**
- Not locked to single provider
- Can test contract compliance across models
- Users can choose based on cost/performance/availability

**Limitations accepted:**
- Some providers cannot fully comply (documented warning)
- Each provider addition requires script changes
- No unified testing across providers yet

### Compliance Matrix

| Provider | Contract Compliance | Recommended |
|----------|---------------------|-------------|
| Claude   | Full                | Yes         |
| Codex    | Full                | Yes         |
| Gemini   | Partial             | No          |
| Mistral  | Partial             | No          |

---
*Reconstructed from commits 26288f4, 413f1c9, 5895bab (2026-01-27 to 2026-01-28)*
