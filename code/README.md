# Code conventions

## Shape
Scripts are A→B: read inputs, write outputs, exit. Clear, documented, logical. No frameworks, no
configuration systems, no generalization beyond this project. Scripts + exported files, not notebooks.

## Header contract — every script, every language
```
# ------------------------------------------------------------------
# 02_cellbender.py
# purpose : remove ambient RNA from raw cellranger matrices
# inputs  : <cellranger>/<library>/raw_feature_bc_matrix.h5      (key: cellranger, config/paths.yaml)
# outputs : <cellbender>/<library>/cellbender.h5                  (key: cellbender)
# env     : $ENV_PY                                               (config/hpc.sh)
# run     : source config/hpc.sh && sbatch code/pipeline/02_cellbender/run.sbatch <library>
# runtime : ~40 min per library on 1 GPU
# written : 261103   by: Claude Code / <name>
# ------------------------------------------------------------------
```
Read every path from config. Loaders:
```r
cfg <- yaml::read_yaml(file.path(Sys.getenv("PROJECT_ROOT"), "config/paths.yaml"))
p   <- function(key) file.path(cfg$root, cfg[[key]])
```
```python
import os, yaml
cfg = yaml.safe_load(open(os.path.join(os.environ["PROJECT_ROOT"], "config/paths.yaml")))
p = lambda key: os.path.join(cfg["root"], cfg[key])
```

## code/pipeline/
Numbered steps, each a folder: `01_<step>/` holding the script and its `run.sbatch`.
Applied identically to every batch. Job scripts carry only their own resource needs
(`--time`, `--mem`, `--cpus-per-task`, `--gres`); account, partition, and QOS come from the
environment via config/hpc.sh. Submit from the repo root after sourcing it:
```bash
source config/hpc.sh && sbatch code/pipeline/01_<step>/run.sbatch
```
Inside run.sbatch, `source "$PROJECT_ROOT/config/hpc.sh"` — sbatch passes the environment through.
Every run.sbatch records its own exit status, because sacct is often unreachable from scotty and
scontrol forgets finished jobs within minutes. First lines after the #SBATCH block:
```bash
set -euo pipefail
trap 'echo $? > "$PROJECT_ROOT/code/pipeline/<step>/out/${SLURM_JOB_ID}.exit"' EXIT
```
A job is judged by that marker (0 = success) and its outputs, never by accounting.

## code/analysis/
One folder per analysis, named for what it is, not when: `qc_summary/`, `cluster_markers/`.
Each analysis is a project in miniature, with the same practices at a smaller size:
```
code/analysis/<name>/
├── README.md     the analysis's living doc (sections below), current state only
├── log/          YYMMDD_HHMM_<topic>.md entries, same format as docs/log/README.md
│   ├── briefs/   the brief behind every subagent spawned for this analysis
│   └── *_audit_<topic>.md   auditor entries
├── NN_<step>.*   scripts, numbered in run order, each with the header contract
└── out/
    ├── tables/   derived tables (committed when < 5 MB; larger ones go to data/derived/)
    ├── plots/    x.pdf + x.png + x.txt legend for every plot (committed when small)
    ├── reports/  rendered summaries, html or pdf (committed when small)
    ├── objects/  large intermediates: rds, h5ad, npz … (gitignored)
    └── jobs/     Slurm stdout/err and <jobid>.exit markers (gitignored)
```
Nothing sits loose in out/, and temporary files go in `scratch/<analysis>/`, never in out/.
Batch-driven projects nest by data state: `out/thru_<batch>/{tables,plots,…}`, where `thru_<batch>`
means all batches up to and including that one. When a new batch lands, add `thru_<newbatch>/` and
rerun. Raw-data directories named for a single batch contain only that batch.

README sections, in this order:
- a header line: `date: YYMMDD · stage: <plan stage> · owner: <who>`
- `## Question`
- `## Inputs` (what was checked about them)
- `## Method`
- `## Planned outputs` (tables and plots)
- `## Reading the result` (what outcome A vs B would mean, written before seeing either)
- `## Status`
- `## Results`
- `## Caveats`

Detail stays in the analysis; it rolls up into the project as one docs/results.md line per result,
plus a docs/log/ entry only when it changes the plan. Every agent that works in the analysis writes
its own log entry here: the project manager, managers, analysts and auditors. Results headed for
docs/ need an auditor entry first.

`code/check_conventions.sh <analysis dir>` (or `--changed`) checks this layout. It also runs
automatically when an `analyst` or `manager` subagent stops (.claude/settings.json), and blocks
the stop until the violations are fixed.

## Plots
Plots are outputs like tables, and most analyses should plan them in the README. Every plot is
saved as `x.pdf` + `x.png` + `x.txt`. The PNG is for quick viewing, by people and by agents. The
legend is written by the same code that draws the plot, from computed values: what is plotted, n,
the statistic or test, the inputs, the script and the date. It is never typed by hand, so it can't
drift from the plot. Copy a helper into the project:
```python
import os
def save_plot(fig, name, legend, outdir):
    """fig: matplotlib figure; legend: text assembled from computed values."""
    os.makedirs(outdir, exist_ok=True)
    fig.savefig(os.path.join(outdir, f"{name}.pdf"))
    fig.savefig(os.path.join(outdir, f"{name}.png"), dpi=150)
    with open(os.path.join(outdir, f"{name}.txt"), "w") as fh:
        fh.write(legend.strip() + "\n")
```
```r
save_plot <- function(p, name, legend, outdir, width = 7, height = 5) {
  # p: ggplot; legend: text assembled from computed values (sprintf / glue)
  dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(file.path(outdir, paste0(name, ".pdf")), p, width = width, height = height)
  ggplot2::ggsave(file.path(outdir, paste0(name, ".png")), p, width = width, height = height, dpi = 150)
  writeLines(trimws(legend), file.path(outdir, paste0(name, ".txt")))
}
```
