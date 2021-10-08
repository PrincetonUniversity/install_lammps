# Della

Della is a heterogeneous cluster composed of more than 250 Intel nodes. The microarchitectures of the nodes are Cascade Lake, SkyLake, Broadwell, Haswell, Ivybridge. Della can be used to run a variety of jobs from single-core to parallel, multi-node. The head node features Intel Broadwell CPUs.

### Mixed-precision version (recommended)

Run the commands below to build LAMMPS in mixed precision for Della:

```
$ ssh <YourNetID>@della.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/lammps_mixed_prec_della.sh
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
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/lammps_double_prec_della.sh
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
