# Cluster and environment settings. The only file a new site should need to edit besides paths.yaml.
# Usage: source config/hpc.sh   (from the repo root, or from inside any sbatch script)
export PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Slurm defaults — sbatch reads these from the environment, so job scripts omit them
export SBATCH_ACCOUNT=pni
export SBATCH_PARTITION=all
export SBATCH_QOS=normal

# Conda
export CONDA_SH=/mnt/cup/PNI-facilities/Computing/sw/pkg/Rhel9/ANACONDAPY/2024.02/etc/profile.d/conda.sh
export ENV_PY=/jukebox/scratch/md6347/envs/scvi_daisy
export ENV_R=/jukebox/scratch/md6347/envs/r4.4
[ -f "$CONDA_SH" ] && source "$CONDA_SH"

# Modules this project uses — uncomment as needed
# module load cellranger/8.0.1
