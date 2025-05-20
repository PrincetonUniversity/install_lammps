# Della (CPU)

[Della](https://researchcomputing.princeton.edu/systems/della) is a heterogeneous cluster composed of AMD and Intel CPUs and NVIDIA GPUs. Della can be used to run a variety of jobs from serial to multinode.

## Della (AMD CPUs)

Della 9 provides about 10,000 AMD CPU cores. See this [build script](della9_amd_double_prec_aocc_aocl.sh):

A sample Slurm script is below (note that gcc-toolset and aocc modules are included which is unusual since these are build tools):

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=4               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)
#SBATCH --constraint=amd
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu

module purge
module load gcc-toolset/14
module load aocc/5.0.0
module load aocl/aocc/5.0.0
module load openmpi/aocc-5.0.0/4.1.6

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_d9_double_aocc -in in.melt
```

## Mixed-precision version (Intel CPUs)

You should favor running on the AMD CPUs over Intel since they are newer and there about 10000 AMD CPU-cores versus 3000 Intel CPU-cores on the "cpu" partition.

Run the commands below to build LAMMPS in mixed precision for Della with the [INTEL](../misc/notes.md#USER-INTEL) package:

```bash
$ ssh <YourNetID>@della8.princeton.edu  # do not use della or della-gpu login node for building the Intel version of LAMMPS
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
#SBATCH --constraint=intel
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu
#SBATCH --constraint=cascade

module purge
module load intel-oneapi/2024.2
module load intel-mpi/intel/2021.13
module load intel-mkl/2024.2

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_intel -sf intel -in in.melt
```

View the [in.melt](../misc/in.melt) file. Users will need to find the optimal values for `nodes`, `ntasks` and `cpus-per-task`. This can be done by conducting a [scaling analysis](https://researchcomputing.princeton.edu/support/knowledge-base/scaling-analysis).


## Della-GPU

### Build from Source (Kokkos)

Run the commands below to build LAMMPS for Della-GPU using the Kokkos backend which will use a GPU-enabled FFT library:

```
$ ssh <YourNetID>@della-gpu.princeton.edu  # do not use della8 for building GPU codes
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/refs/heads/master/01_installing/ins/della/lammps_kokkos_della.sh
# use a text editor to inspect della_gpu_lammps_gcc.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash della_gpu_lammps_gcc.sh | tee install_lammps.log
```

### Another option

If the Kokkos build is not a solution for you then consider the one below. It uses FFFW as the FFT library which will not use the GPU. If you do not need to calculate FFT's then this is fine.

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
module load cudatoolkit/12.8

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_gpu -sf gpu -pk gpu 1 -in in.melt.gpu
```

See the input file: [in.melt.gpu](../misc/in.melt.gpu).


## Getting Help

If you encounter any difficulties while working with LAMMPS then please send an email to <a href="mailto:cses@princeton.edu">cses@princeton.edu</a> or attend a [help session](https://researchcomputing.princeton.edu/support/help-sessions).
