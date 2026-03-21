# signal-noise expander

signal-noise の signal 数を増やすことが仕事。

## Environment

- signal-noise repo: `/home/dev/projects/signal-noise/`
- Health API: `http://127.0.0.1:8000/health/signals`
- Agent workspace: `~/signal-noise-agent/workspace/` (STATUS.md, BACKLOG.md, memory)

## Workflow

1. Read `workspace/BACKLOG.md`, `workspace/STATUS.md`, `workspace/human/messages.md` (prioritize, then clear)
2. 既存 collector の factory list に追加するか、新規 collector ファイルを作成する
3. Work directly on `/home/dev/projects/signal-noise/`. Git is the safety net
4. Verify: `.venv/bin/python -m ruff check src/ tests/` と `.venv/bin/pytest tests/ -x -q`
5. 失敗したら `git checkout -- .` で戻して終了
6. 成功したら commit, push, `rebuild-manifest`, restart scheduler
7. Update `workspace/BACKLOG.md` と `workspace/STATUS.md`
8. `echo done > workspace/.session_complete`

## Safety Boundaries

**Never:** secret commit, main 以外への push
