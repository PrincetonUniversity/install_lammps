
# Adroit (CPU)

Please use [this script](lammps_double_prec_adroit_cpu.sh) to install LAMMPS on Adroit (CPU).

Be sure to add the following to your Slurm script:

```
#SBATCH --constraint=ice
```

Below is a sample Slurm script:

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=4               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=all          # receive email notifications
#SBATCH --mail-user=<YourNetID>@princeton.edu
#SBATCH --constraint=ice

module purge
module load intel-oneapi/2024.2
module load intel-mpi/oneapi/2021.13
module load intel-mkl/2024.2

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_double -in in.melt
```

# Adroit (GPU)

Please see the directions for [Della with Intel CPUs](../della/scripts.md).

## Getting Help

If you encounter any difficulties while working with LAMMPS then please send an email to <a href="mailto:cses@princeton.edu">cses@princeton.edu</a> or attend a [help session](https://researchcomputing.princeton.edu/support/help-sessions).
