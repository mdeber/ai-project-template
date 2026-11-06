# __PROJECT__

__ONE_LINE_DESCRIPTION__
Lab: __LAB__ · Repo root: __REPO_ROOT__
Site conventions (paths, compute budget, Slurm, conda, tmux) come from ~/.claude/CLAUDE.md
and are not repeated here.

@docs/STATUS.md

## Layout
- `docs/` — the lab notebook. Read it; write to it.
  - `background.md`  the question, what would change the plan, what is known (cited inline)
  - `data.md`        registry of every data directory, batch, and metadata table
  - `plan.md`        stages: inputs, method, outputs, decision criteria
  - `results.md`     index of outputs + current interpretation per stage
  - `STATUS.md`      now / next / open questions (auto-loaded above)
  - `log/`           timestamped session records. The raw record everything else is derived from.
  - `research/`      raw research notes (paper reads, software evaluations), distilled into background.md
- `config/paths.yaml`, `config/hpc.sh` — every path and cluster setting. Code never hardcodes these.
- `code/pipeline/`  numbered steps, applied identically to every batch
- `code/analysis/`  one folder per analysis: README.md + scripts + out/
- `metadata/`       small committed tables (animals, libraries, …); columns documented in docs/data.md
- `data/`           large files, gitignored; every subdirectory is described in docs/data.md
- `envs/`           exported environment yamls
- `scratch/`        gitignored, throwaway

## Session protocol
**Start.** STATUS.md is already loaded. Read the plan.md stage you are working on. Read results.md
if you touch results. Do not read log/ unless asked why something was done, or you are consolidating.

**Work.** Exploration that might matter goes in code/analysis/<name>/. Throwaway goes in scratch/.
Every path comes from config/. Scripts + exported files, not notebooks.

**End of session, or on "consolidate" — in this order:**
1. Write `docs/log/YYMMDD_HHMM_<topic>.md` (format in docs/log/README.md). Tag DECISION and DEAD END.
2. Overwrite `docs/STATUS.md`.
3. Add any new output to `docs/results.md`. The full interpretation goes in the analysis README.
4. `git add` and commit. Message: `<stage>: <what changed>`. Never commit data or files > 5 MB.

**Consolidate** means: read every log entry since `last consolidated` in STATUS.md, bring the living
docs (background, data, plan, results) up to date, then set `last consolidated` to now.

## Extended autonomy (only when Mike asks for it)
Mike, or a session he instructs, starts `~/.claude/bin/claude-loop.sh "<goal>"` from the repo root,
detached in tmux as `cc-loop-<project>`. Each iteration is a fresh headless session: it reads
STATUS.md and the active plan stage, works, submits Slurm jobs, and ends by running the end-of-session
protocol above (log entry with `mode: unattended`, STATUS, commit) and writing ONE line to
`scratch/loop/state`: `WAITING <jobid...>` (re-enter when they finish), `CONTINUE` (more to do now),
`DONE` (goal reached), or `NEEDS_MIKE <why>` (stop). The driver waits for the jobs and re-enters.
Plan decision points are `NEEDS_MIKE` stops unless the goal names which decisions Claude may take.
Transcripts: `scratch/loop/iter_<n>.log`; driver log: `scratch/loop/driver.log`.

## Rules
- If it matters, it is in docs/. Nothing important lives only in this session or in Claude memory.
- Living docs hold current state only. Narrative, history, and reasoning go in log/.
- Ask before: editing background.md; restructuring plan.md stages; deleting anything in data/ or
  out/; any git operation beyond add/commit.
- Scripts are A→B: read inputs, write outputs, documented header (code/README.md). No frameworks,
  no abstraction beyond what this project needs.
- Log files are timestamped. Analyses are not dated by folder name; the date is in the README header.
  In batch-driven projects, analysis outputs go in `thru_<batch>/` subfolders (see code/README.md).

## Project-specific deviations
(none yet)
