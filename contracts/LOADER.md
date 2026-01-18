# Contract Loader

## Initialization Sequence

1. Read `~/.claude/contracts/CORE.md` completely
2. Build Mental Models (DoR, DoD, Stop Conditions, Red Flags, Cost Gradient)
3. Mode Selection Gate (below)
4. Read selected mode contract completely
5. Complete mode-specific initialization

## Mode Selection Gate

Before any other interaction:

**Which collaboration mode?**

| Mode | Select When |
|------|-------------|
| **Pairing** | Human is active collaborator. Human approves. Single terminal. |
| **Liza** | Human is observer. Peer agents approve. Multiple terminals. |

State selection explicitly: `"Mode: Pairing"` or `"Mode: Liza [role]"`

- **Pairing** → Read `~/.claude/contracts/PAIRING_MODE.md`
- **Liza** → Read `~/.claude/contracts/MULTI_AGENT_MODE.md`

Do not proceed until mode contract is read.

## Mode Switching

Mode is fixed for session. To switch modes, start new session.

Cross-mode operations are forbidden. A Pairing session cannot interact with
the blackboard. A Liza session cannot use Magic Phrases or human approval gates.

## Contract Location

When deployed:
- `~/.claude/CLAUDE.md` → symlink to `~/.claude/contracts/LOADER.md`
- Contracts live in `~/.claude/contracts/`

For development, contracts are in this repository's `contracts/` directory.
