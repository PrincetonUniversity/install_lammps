# LAMMPS on TigerGPU

This cluster is composed of 80 nodes with 28 CPU-cores per node and 4 NVIDIA P100 GPUs per node. TigerGPU should only be used for multi-node jobs that take advantage of GPUs.

### Mixed-precision version

```
$ ssh <YourNetID>@tigergpu.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/tigerGpu_user_intel.sh
$ bash tigerGpu_user_intel.sh | tee lammps_mixed.log
```

The LAMMPS build system will add `-qopenmp`, `-restrict` and `-xHost` to the CXX_FLAGS. Note that the build above includes the MOLECULE, RIGID and KSPACE packages. If you do not need these for your simulations then you should remove them from the .sh file after running `wget`.

The following Slurm script can be used to run the job on the TigerGPU cluster:

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=4               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --gres=gpu:1             # number of gpus per node
#SBATCH --time=00:01:00          # total run time limit (HH:MM:SS)

module purge
module load intel/18.0/64/18.0.3.222 intel-mpi/intel/2018.3/64
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_tigerGpu -sf gpu -in in.melt
```

The user should vary the various quantities in the Slurm script to find the optimal values.

### Double-precision version

Connect with: `ssh <YourNetID>@tigergpu.princeton.edu`.

```
# make sure you are on tigergpu.princeton.edu

module purge
module load intel/19.0/64/19.0.5.281 intel-mpi/intel/2019.3/64 cudatoolkit/10.2

# copy and paste the next 6 lines into the terminal
cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=tigerGpuD \
-D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc \
-D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost -mtune=broadwell -DNDEBUG" \
-D PKG_USER-OMP=yes -D PKG_MOLECULE=yes -D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=no \
-D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=double -D GPU_ARCH=sm_60 -D CUDPP_OPT=yes ../cmake

make -j 10
make test
make install
```

The LAMMPS build system will add `-qopenmp` and `-restrict` to the CXX_FLAGS. Note that the build above includes the MOLECULE, RIGID and KSPACE packages. If you do not need these for your simulations then you should remove them.

The following Slurm script can be used to run the job on the TigerGPU cluster:

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=7               # total number of tasks across all nodes
#SBATCH --cpus-per-task=2        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --gres=gpu:1             # number of gpus per node
#SBATCH --time=00:01:00          # total run time limit (HH:MM:SS)

module purge
module load intel/19.0/64/19.0.5.281 intel-mpi/intel/2019.3/64
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
 
srun $HOME/.local/bin/lmp_tigerGpuD -sf gpu -in in.melt.gpu
```

The user should vary the various quantities in the Slurm script to find the optimal values.

Here is a sample LAMMPS script called `in.melt.gpu`:

```
package         gpu 1

units           lj
atom_style      atomic

lattice         fcc 0.8442
region          box block 0 30 0 30 0 30
create_box      1 box
create_atoms    1 box
mass            1 1.0

velocity        all create 1.0 87287

pair_style      lj/cut/gpu 2.5 # explicit gpu pair style
pair_coeff      1 1 1.0 1.0 2.5

neighbor        0.3 bin
neigh_modify    every 20 delay 0 check no

fix             1 all nve
fix             2 all langevin 1.0 1.0 1.0 48279

timestep        0.005

thermo          5000
run             10000
```

To use 2 GPUs, replace `package gpu 1` with `package gpu 2` and `-sf gpu` with `-sf gpu -pk gpu 2` and `#SBATCH --gres=gpu:1` with `#SBATCH --gres=gpu:2`.
