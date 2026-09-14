# StellarAI

## AMD CPU Nodes

Run these commands to install LAMMPS with the AMD software stack on StellarAI:

```
$ ssh <YourNetID>@stellarai-amd.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/stellarai/stellarai_amd_double_prec_aocc_aocl.sh
# use a text editor to inspect stellarai_amd_double_prec_aocc_aocl.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash stellarai_amd_double_prec_aocc_aocl.sh | tee install_lammps.log
```

The executable will be installed into `~/.local/bin` which is included in your `PATH` by default. See the `01_installing/ins/stellarai` directory in this repo for alternative builds.

The following Slurm script can be used:

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=96              # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=all          # receive email notifications
#SBATCH --mail-user=<YourNetID>@princeton.edu

module purge
module load aocc/5.2.0
module load aocl/aocc/ST/5.3.0
module load openmpi/aocc-5.2.0/5.0.10

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_cpu -in in.melt
```
