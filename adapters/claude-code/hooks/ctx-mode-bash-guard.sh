#!/usr/bin/env bash
# Blocks Bash commands likely to produce >20 lines of output.
# Forces routing through ctx_batch_execute to protect context window.
COMMAND=$(jq -r '.tool_input.command // ""')

SHOULD_BLOCK=0

# grep -r (recursive grep — always large)
echo "$COMMAND" | grep -qE 'grep[[:space:]]+-[a-zA-Z]*r[[:space:]]' && SHOULD_BLOCK=1

# ls -R (recursive listing)
echo "$COMMAND" | grep -qE 'ls[[:space:]]+-[a-zA-Z]*R' && SHOULD_BLOCK=1

# npm list, pip list/freeze
echo "$COMMAND" | grep -qE 'npm[[:space:]]+list|pip[[:space:]]+(list|freeze)' && SHOULD_BLOCK=1

# ps aux / ps -ef
echo "$COMMAND" | grep -qE 'ps[[:space:]]+(aux|-ef)' && SHOULD_BLOCK=1

# env / printenv standalone
echo "$COMMAND" | grep -qE '^[[:space:]]*(env|printenv)[[:space:]]*$' && SHOULD_BLOCK=1

# find without pipe to wc or head (unbounded file search)
if echo "$COMMAND" | grep -qE '^[[:space:]]*find[[:space:]]' && ! echo "$COMMAND" | grep -qE '\|[[:space:]]*(wc|head)'; then
  SHOULD_BLOCK=1
fi

if [ "$SHOULD_BLOCK" -eq 1 ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"context-mode: command may produce >20 lines. Use mcp__plugin_context-mode_context-mode__ctx_batch_execute instead to protect context window."}}\n'
fi
