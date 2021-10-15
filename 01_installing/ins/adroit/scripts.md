# Adroit (GPU)

### Mixed-precision A100 GPU version

Run the commands below to build a version of LAMMPS for the A100 GPUs with [USER-INTEL](../misc/notes.md#USER-INTEL):

```
$ ssh <YourNetID>@adroit.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/adroit/lammps_mixed_prec_adroit_gpu_a100.sh
# use a text editor to inspect lammps_mixed_prec_adroit_gpu_a100.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash lammps_mixed_prec_adroit_gpu_a100.sh | tee install_lammps.log
```

The executable will be installed into `~/.local/bin` which is included in your `PATH` by default.

Below is a sample Slurm script:

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=14              # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --gres=gpu:1             # number of GPUs per node
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu
#SBATCH --constraint=a100

module purge
module load intel/19.1.1.217
module load intel-mpi/intel/2019.7
module load cudatoolkit/11.4
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_adroitGPU -sf gpu -pk gpu 1 -in in.melt.gpu
```

View the [in.melt.gpu](../misc/in.melt.gpu) file. Users will need to find the optimal values for `nodes`, `ntasks`, `cpus-per-task` and `gres`. This can be done by conducting a [scaling analysis](https://researchcomputing.princeton.edu/support/knowledge-base/scaling-analysis).

# Adroit (CPU)

### Double-precision CPU version

If for some reason you don't want to use the GPU nodes then the following directions will produce a parallel version of LAMMPS for the CPU nodes of Adroit:

```
$ ssh <YourNetID>@adroit.princeton.edu
$ cd software  # or another directory
$ https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/adroit/lammps_double_prec_adroit_cpu.sh
# use a text editor to inspect lammps_double_prec_adroit_cpu.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash lammps_double_prec_adroit_cpu.sh | tee install_lammps_cpu.log
```

The LAMMPS build system will add `-qopenmp` and `-restrict` to the CXX_FLAGS.

Below is a sample Slurm script:

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=4               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=1G         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu

module purge
module load intel/19.1.1.217
module load intel-mpi/intel/2019.7
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_adroit -in in.melt
```

View the [in.melt](../misc/in.melt) file. Users will need to find the optimal values for `nodes`, `ntasks` and `cpus-per-task`. This can be done by conducting a [scaling analysis](https://researchcomputing.princeton.edu/support/knowledge-base/scaling-analysis).

## Getting Help

If you encounter any difficulties while working with LAMMPS then please send an email to <a href="mailto:cses@princeton.edu">cses@princeton.edu</a> or attend a [help session](https://researchcomputing.princeton.edu/support/help-sessions).
