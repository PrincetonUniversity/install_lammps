# Della (CPU)

[Della](https://researchcomputing.princeton.edu/systems/della) is a heterogeneous cluster. Della can be used to run a variety of jobs from serial to parallel, multinode.

### Mixed-precision version (recommended)

Run the commands below to build LAMMPS in mixed precision for Della with the [INTEL](../misc/notes.md#USER-INTEL) package:

```bash
$ ssh <YourNetID>@della.princeton.edu
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
#SBATCH --constraint=cascade,skylake

module purge
module load intel/19.1.1.217
module load intel-mpi/intel/2019.7
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_della -sf intel -in in.melt
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

Run the commands to build LAMMPS for Della-GPU

```
$ ssh <YourNetID>@della-gpu.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/della/della_gpu_lammps_gcc.sh
# use a text editor to inspect ldella_gpu_lammps_gcc.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
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
module load openmpi/gcc/4.1.0
module load cudatoolkit/11.4
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_della_gpu_gcc -sf gpu -pk gpu 1 -in in.melt.gpu
```

### NGC Container

Right now it appears the best approach is to use the [NGC container](https://ngc.nvidia.com/catalog/containers/hpc:lammps) with 1 CPU-core and 1 GPU.

The [NGC container](https://ngc.nvidia.com/catalog/containers/hpc:lammps) provides the following packages:

```
ASPHERE KOKKOS KSPACE MANYBODY MISC MOLECULE MPIIO REPLICA RIGID SNAP USER-REAXC
```

Obtain the image:

```
$ ssh <YourNetID>@della-gpu.princeton.edu
$ mkdir -p software/lammps_container
$ cd software/lammps_container
$ singularity pull docker://nvcr.io/hpc/lammps:10Feb2021
```

```
#!/bin/bash
#SBATCH --job-name=lammps        # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=8G         # memory per cpu-core (4G per cpu-core is default)
#SBATCH --gres=gpu:1             # number of gpus per node
#SBATCH --time=00:10:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu

set -euf -o pipefail
# set -e (exit immediately if any line in the script fails)
# set -u (references to undefined variables produce error)
# set -f (disable filename expansion)
# set -o pipefail (return error code of failed commands in the pipeline)

# number of GPUs per node
gpu_count=$(printf ${SLURM_JOB_GPUS} | sed 's/[^0-9]*//g' | wc --chars)

module purge
#module load openmpi/gcc/4.1.0
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

singularity run --nv -B $PWD:/host_pwd --pwd /host_pwd $HOME/software/lammps_container/lammps_10Feb2021.sif ./run_lammps.sh

#srun --mpi=pmi2 \
#singularity run --nv -B $PWD:/host_pwd --pwd /host_pwd lammps_10Feb2021.sif \
#lmp -k on g ${gpu_count} -sf kk -pk kokkos cuda/aware on neigh full comm device binsize 2.8 -in in.melt
```

Make `run_lammps.sh` executable:

```
$ chmod u+x run_lammps.sh
```

Below is the contents of run_lammps.sh:

```
$ cat run_lammps.sh

#!/bin/bash
set -euf -o pipefail
readonly gpu_count=${1:-$(nvidia-smi --list-gpus | wc -l)}

echo "Running Lennard Jones 8x4x8 example on ${gpu_count} GPUS..."
mpirun -n ${gpu_count} lmp -k on g ${gpu_count} -sf kk -pk kokkos cuda/aware on neigh full comm device binsize 2.8 -in in.melt
```

## Getting Help

If you encounter any difficulties while working with LAMMPS then please send an email to <a href="mailto:cses@princeton.edu">cses@princeton.edu</a> or attend a [help session](https://researchcomputing.princeton.edu/support/help-sessions).
