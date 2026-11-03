# __PROJECT__

__ONE_LINE_DESCRIPTION__

**If you are an AI or a new collaborator arriving cold, read in this order:**
1. `docs/background.md` — the question and what is known
2. `docs/plan.md` — how we are answering it, stage by stage
3. `docs/STATUS.md` — where things stand now
4. `docs/results.md` — what we have found so far
5. `CLAUDE.md` — how work is organized and how to contribute without breaking conventions

Every data directory and metadata table is described in `docs/data.md`. Every path and cluster
setting lives in `config/`; to run this on another system, edit `config/paths.yaml` and
`config/hpc.sh` and nothing else. Reasoning behind decisions, including abandoned approaches, is in
`docs/log/` — search for `DECISION` and `DEAD END`.

## Reproducing
```bash
source config/hpc.sh                       # cluster defaults + conda environments
sbatch code/pipeline/01_<step>/run.sbatch  # pipeline steps, in order, per batch
# analyses: see each code/analysis/<name>/README.md for its run command
```

## Citation
(added at publication)
