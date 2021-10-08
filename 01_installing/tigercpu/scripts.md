# LAMMPS on TigerCPU

This cluster is composed of 408 nodes with 40 CPU-cores per node. TigerCPU should be used for running multi-node parallel jobs. Single-node jobs should be run on Della.

### Mixed-precision version

```
$ ssh <YourNetID>@tigercpu.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/tigerCpu_user_intel.sh
$ bash tigerCpu_user_intel.sh | tee lammps_mixed.log
```

Note that the LAMMPS build system will add `-qopenmp`, `-restrict` and `-xHost` to the CXX_FLAGS.

Below is a sample Slurm script:

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=4              # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)

module purge
module load intel/18.0/64/18.0.3.222 intel-mpi/intel/2018.3/64
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_tigerCpu -sf intel -in in.melt
```

The user should vary the various quantities in the Slurm script to find the optimal values.

### Double-precision version

```
# make sure you are on tigercpu.princeton.edu

module purge
module load intel/19.0/64/19.0.5.281 intel-mpi/intel/2019.3/64

# copy and paste the next 4 lines into the terminal
cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tigerCpuD -D ENABLE_TESTING=yes \
-D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_CXX_COMPILER=icpc -D CMAKE_BUILD_TYPE=Release \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost -mtune=skylake-avx512 -DNDEBUG" \
-D PKG_USER-OMP=yes -D PKG_MOLECULE=yes ../cmake

make -j 10
make test
make install
```

Note that the LAMMPS build system will add `-qopenmp` and `-restrict` to the CXX_FLAGS.

Below is a sample Slurm script:

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=10              # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)

module purge
module load intel/19.0/64/19.0.5.281 intel-mpi/intel/2019.3/64
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_tigerCpuD -sf omp -in in.melt
```

The user should vary the various quantities in the Slurm script to find the optimal values.

Here is a sample LAMMPS script called in.melt:

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
