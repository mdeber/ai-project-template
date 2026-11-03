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
# written : 261103   by: Claude Code / Mike
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

## code/analysis/
One folder per analysis, named for what it is, not when: `qc_summary/`, `cluster_markers/`.
```
code/analysis/<name>/
├── README.md     purpose · date written · inputs · what was done · what it showed · caveats
├── <scripts>
└── out/          gitignored, except out/tables/ (small derived tables) and out/final/ (figure panels)
```
Batch-driven projects: outputs for a given data state go in `out/thru_<batch>/`, meaning all
batches up to and including that one. When a new batch lands, add `thru_<newbatch>/` and rerun.
Raw-data directories named for a single batch contain only that batch.

Derived tables other code depends on are committed in out/tables/ if small (< 5 MB); larger ones
go to data/derived/ and are registered in docs/data.md.
