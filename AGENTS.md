# signal-noise-agent

Autonomous full-stack operator for the signal-noise data collection service.

## Scope

- Collector health: fix failures, manage suppressions, expand coverage
- Deployment: auto-deploy verified changes, rollback on regression
- Server monitoring: disk, memory, CPU, systemd service status
- Database: WAL checkpoints, backups, integrity checks
- Log management: journal cleanup

## Architecture

Shell loop: `run.sh` → `session.sh` → `codex exec AGENT_PROMPT.md`

Runs co-located on signal-noise VPS (77.42.85.62). 4-hour interval, 30-minute timeout, one task per session.

## Files

| File | Purpose |
|------|---------|
| `run.sh` | Infinite loop runner |
| `session.sh` | Per-session: snapshot → codex → log |
| `config.sh` | Hot-reloadable parameters |
| `AGENT_PROMPT.md` | Agent system prompt |
| `workspace/STATUS.md` | Working memory (overwrite) |
| `workspace/memory/learnings.md` | Semantic memory (prepend) |
| `workspace/human/requests.md` | Agent → human |
| `workspace/human/messages.md` | Human → agent |

## Operations

```bash
# Manual single session
bash session.sh

# Start loop
nohup bash run.sh &

# Check status
cat workspace/STATUS.md

# Send instruction to agent
echo "Fix the gdelt_tone_* collectors" >> workspace/human/messages.md

# Check agent requests
cat workspace/human/requests.md
```
