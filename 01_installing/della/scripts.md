# Della (CPU)

Della is a heterogeneous cluster composed of more than 250 Intel nodes. The microarchitectures of the nodes are Cascade Lake, SkyLake, Broadwell, Haswell, Ivybridge. Della can be used to run a variety of jobs from single-core to parallel, multi-node. The head node features Intel Broadwell CPUs.

### Mixed-precision version (recommended)

Run the commands below to build LAMMPS in mixed precision for Della:

```
$ ssh <YourNetID>@della.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/della/lammps_mixed_prec_della.sh
$ bash lammps_mixed_prec_della.sh | tee lammps_mixed.log
```

The LAMMPS build system will add `-qopenmp`,  `-restrict` and `-xHost` to the CXX_FLAGS. It is normal to see a large number of messages containing the phrase "has been targeted for automatic cpu dispatch".

The following Slurm script can be used to run the job on Della:

```
#!/bin/bash
#SBATCH --job-name=lj-melt                       # create a short name for your job
#SBATCH --nodes=1                                # node count
#SBATCH --ntasks=16                              # total number of tasks across all nodes
#SBATCH --cpus-per-task=1                        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G                         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00                          # total run time limit (HH:MM:SS)

module purge
module load intel/18.0/64/18.0.3.222 intel-mpi/intel/2018.3/64
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_della -sf intel -in in.melt
```

Users should vary the various quantities in the Slurm script to find the optimal values. If you fail to exclude the Intel Ivy Bridge nodes on Della then you will see an error message like "Please verify that both the operating system and the processor support Intel(R) MOVBE, FMA, BMI, LZCNT and AVX2 instructions."

### Double-precision version

Run the commands below to build LAMMPS in double precision for Della:

```
$ ssh <YourNetID>@della.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/della/lammps_double_prec_della.sh
$ bash lammps_double_prec_della.sh | tee lammps_double.log
```

The LAMMPS build system will add `-qopenmp` and  `-restrict` to the CXX_FLAGS. It is normal to see a large number of messages containing the phrase "has been targeted for automatic cpu dispatch".

The following Slurm script can be used to run the job on Della:

```
#!/bin/bash
#SBATCH --job-name=lj-melt                       # create a short name for your job
#SBATCH --nodes=1                                # node count
#SBATCH --ntasks=16                              # total number of tasks across all nodes
#SBATCH --cpus-per-task=1                        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G                         # memory per cpu-core
#SBATCH --time=00:05:00                          # total run time limit (HH:MM:SS)

module purge
module load intel/19.0/64/19.0.5.281 intel-mpi/intel/2018.3/64
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_della_double -sf omp -in in.melt
```

Below is a sample LAMMPS script called `in.melt`:

```
units           lj
atom_style      atomic

lattice         fcc 0.8442
region          box block 0 30 0 30 0 30
create_box      1 box
create_atoms    1 box
mass            1 1.0

velocity        all create 1.0 87287

pair_style      lj/cut 2.5
pair_coeff      1 1 1.0 1.0 2.5

neighbor        0.3 bin
neigh_modify    every 20 delay 0 check no

fix             1 all nve
fix             2 all langevin 1.0 1.0 1.0 48279

timestep        0.005

thermo          5000
run             10000
```

# Della-GPU

It is proving difficult to find a procedure to build LAMMPS that performs optimally on della-gpu. Right now it appears the best approach is to use the [NGC container](https://ngc.nvidia.com/catalog/containers/hpc:lammps) with 1 CPU-core and 1 GPU.

### NGC Container

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

### Build from Source

```
$ ssh <YourNetID>@della-gpu.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/della/della_gpu_lammps_double_gcc.sh
$ bash della_gpu_lammps_double_gcc.sh | tee lammps.log
```

Be sure include the environments modules in the Bash script in your Slurm script (except cmake). You should find that all the tests pass when installing. The procedure above does everything in double precision which is probably unnecessary for your work. Attempts to use single precision FFTs and GPU kernels led to tests failing because of very slight differences in calculated versus expected values. The processors on the GPU nodes of Della are AMD. The user-intel can be used (even though processors are AMD) but it produces failed unit tests. Write to cses@princeton.edu to find the best way to use LAMMPS on della-gpu.
