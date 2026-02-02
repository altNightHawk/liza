#!/bin/bash
# Atomically initiate context exhaustion handoff
# Usage: liza-handoff.sh <task-id> <summary> <next-action>

set -euo pipefail

TASK_ID="${1:-}"
SUMMARY="${2:-}"
NEXT_ACTION="${3:-}"

if [ -z "$TASK_ID" ] || [ -z "$SUMMARY" ] || [ -z "$NEXT_ACTION" ]; then
    echo "Usage: $0 <task-id> <summary> <next-action>" >&2
    exit 1
fi

if [ -z "${LIZA_AGENT_ID:-}" ]; then
    echo "ERROR: LIZA_AGENT_ID is required" >&2
    exit 1
fi

SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
source "$SCRIPT_DIR/liza-common.sh"
PROJECT_ROOT=$(get_project_root)
STATE="$PROJECT_ROOT/.liza/state.yaml"
TIMESTAMP=$(iso_timestamp)

require_task_exists "$TASK_ID" "$STATE"

SUMMARY="$SUMMARY" NEXT_ACTION="$NEXT_ACTION" "$SCRIPT_DIR/liza-lock.sh" modify \
  yq -i "
    (.tasks[] | select(.id == \"$TASK_ID\")) |= (
      .handoff_pending = true |
      .history = ((.history // []) + [{\"time\": \"$TIMESTAMP\", \"event\": \"handoff_initiated\", \"agent\": \"$LIZA_AGENT_ID\", \"summary\": strenv(SUMMARY), \"next_action\": strenv(NEXT_ACTION)}])
    ) |
    .agents.\"$LIZA_AGENT_ID\".status = \"HANDOFF\"
  " "$STATE"
