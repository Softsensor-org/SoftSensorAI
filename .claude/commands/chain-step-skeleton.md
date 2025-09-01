# Step <N> of <M> — <TASK>

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
</context>

<input>
{PASTE PRIOR OUTPUT HERE, WRAPPED IN TAGS — e.g., <risks>…</risks>}
</input>

<goal>Describe the single outcome this step must produce.</goal>

<plan>
- Acceptance checks (objective).
- Exact commands you will run (if any).
- Artifacts to write (filenames/paths).
</plan>

<thinking>Keep brief; enumerate options/risks; then choose.</thinking>

<work>Do the work focused on the goal. Show a unified diff for code.</work>

<review>
- Do outputs satisfy acceptance checks? If not, repair now.
- Note open questions for the next step.
</review>

<handoff>Summarize outputs and re-emit the main artifact inside a tag.</handoff>
