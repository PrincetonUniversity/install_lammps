# Della (CPU)

[Della](https://researchcomputing.princeton.edu/systems/della) is a heterogeneous cluster. Della can be used to run a variety of jobs from serial to parallel, multinode.

### Mixed-precision version (recommended)

Run the commands below to build LAMMPS in mixed precision for Della with the [INTEL](../misc/notes.md#USER-INTEL) package:

```bash
$ ssh <YourNetID>@della.princeton.edu  # do not use the della-gpu login node for building CPU codes
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/della/lammps_mixed_prec_della.sh
# use a text editor to inspect lammps_mixed_prec_della.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash lammps_mixed_prec_della.sh | tee lammps_mixed.log
```

The following Slurm script can be used to run the job on Della:

```bash
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=4               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu
#SBATCH --constraint=cascade

module purge
module load intel/2024.0
module load intel-mpi/intel/2021.7.0
module load intel-mkl/2024.0

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_intel -sf intel -in in.melt
```

View the [in.melt](../misc/in.melt) file. Users will need to find the optimal values for `nodes`, `ntasks` and `cpus-per-task`. This can be done by conducting a [scaling analysis](https://researchcomputing.princeton.edu/support/knowledge-base/scaling-analysis).


### Double-precision version

Make these changes for the double-precision version:

```
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/della/lammps_double_prec_della.sh
```

```
srun $HOME/.local/bin/lmp_della_double -in in.melt
```

# Della-GPU

### Build from Source

Run the commands below to build LAMMPS for Della-GPU:

```
$ ssh <YourNetID>@della-gpu.princeton.edu  # do not use della8 for building GPU codes
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/della/della_gpu_lammps_gcc.sh
# use a text editor to inspect della_gpu_lammps_gcc.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash della_gpu_lammps_gcc.sh | tee install_lammps.log
```

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=8               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --gres=gpu:1             # number of GPUs per node
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu

module purge
module load fftw/gcc/3.3.9
module load openmpi/gcc/4.1.2
module load cudatoolkit/12.6

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_gpu -sf gpu -pk gpu 1 -in in.melt.gpu
```

See the input file: [in.melt.gpu](../misc/in.melt.gpu).

## Getting Help

If you encounter any difficulties while working with LAMMPS then please send an email to <a href="mailto:cses@princeton.edu">cses@princeton.edu</a> or attend a [help session](https://researchcomputing.princeton.edu/support/help-sessions).
