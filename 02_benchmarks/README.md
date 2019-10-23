## Benchmarks

The performance of the executable can be greatly improved by building it with external packages such as OPT, USER-OMP and USER-INTEL. Most MD simulations do not need to solve the equations of motion precisely. Our conclusions from the benchmarks are that the USER-OMP, USER-INTEL and OPT packages each lead to a speed-up. The USER-INTEL package has the biggest performance boost and it rivals the acceleration obtained from a GPU.

### 1. Lennard-Jones fluid

The first benchmark is a Lennard-Jones fluid with N=108000, T=1, rho=0.8442 and rc=2.5:

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

When a GPU is used, one needs to add `package gpu 1` and replace `lj/cut 2.5` with `lj/cut/gpu 2.5` in the LAMMPS script above.

The following benchmarks were produced on October 23, 2019:


| build                 | time (s)  | cluster       |  ntasks  |  cpus-per-task  | total cores |  GPU  |
|:----------------------|----------:|:-------------:|---------:|:---------------:|------------:|:-----:|
| lmp_tigerGpu (mixed)  |   48.0    | TigerGPU      |   2      | 1               |  2          | 1     |
| lmp_tigerGpu (mixed)  |   29.7    | TigerGPU      |   4      | 1               |  4          | 1     |
| lmp_tigerGpuD (double)|   33.6    | TigerGPU      |   4      | 1               |  4          | 1     |
| lmp_tigerGpu (mixed)  |   22.7    | TigerGPU      |   4      | 1               |  4          | 2     |
| lmp_tigerGpu (mixed)  |   20.2    | TigerGPU      |   7      | 1               |  7          | 1     |
| lmp_tigerGpu (mixed)  |   19.3    | TigerGPU      |   7      | 2               |  14         | 1     |
| lmp_tigerGpu (mixed)  |   20.3    | TigerGPU      |   14     | 1               |  14         | 1     |
| lmp_tigerGpuD (double)|   21.9    | TigerGPU      |   14     | 1               |  14         | 1     |
| lmp_tigerGpu (mixed)  |   14.2    | TigerGPU      |   14     | 1               |  14         | 2     |
| lmp_tigerGpuD (double)|   16.3    | TigerGPU      |   14     | 1               |  14         | 2     |
| lmp_tigerCpu (mixed)  |   75.7    | TigerCPU      |   4      | 1               |  4          | 0     |
| lmp_tigerCpu (mixed)  |   50.7    | TigerCPU      |   7      | 1               |  7          | 0     |
| lmp_tigerCpu (mixed)  |   25.6    | TigerCPU      |   14     | 1               |  14         | 0     |
| lmp_tigerCpu (mixed)  |   38.2    | TigerCPU      |   7      | 2               |  14         | 0     |
| lmp_tigerCpuD (double)|   47.0    | TigerCPU      |   7      | 2               |  14         | 0     |
| lmp_tigerCpuD (double)|   38.4    | TigerCPU      |   14     | 1               |  14         | 0     |
| lmp_traverse (double) |   51.3    | Traverse      |    4     | 1               |   4         | 1     |
| lmp_traverse (double) |   36.0    | Traverse      |    7     | 1               |   7         | 1     |
| lmp_traverse (double) |   33.6    | Traverse      |   14     | 1               |  14         | 1     |
| lmp_traverse (double) |   48.0    | Traverse      |   28     | 1               |  28         | 1     |
| lmp_traverse (double) |   39.9    | Traverse      |    7     | 2               |  14         | 1     |
| lmp_traverse (double) |   25.1    | Traverse      |   14     | 1               |  14         | 2     |
| lmp_traverse (double) |   32.2    | Traverse      |    7     | 1               |   7         | 2     |
| lmp_traverse (double) |   25.6    | Traverse      |    21    | 1               |   21        | 2     |
| lmp_della (mixed)     |  123.0    | Della         |    4     | 1               |   4         | 0     |
| lmp_della (mixed)     |   25.2    | Della         |   14     | 1               |  14         | 0     |
| lmp_della (double)    |   48.4    | Della         |   14     | 1               |  14         | 0     |
| lmp_della (mixed)     |   26.1    | Della         |   21     | 1               |  21         | 0     |
| lmp_adroit (double)   |   139.4   | Adroit        |    4     | 1               |   4         | 0     |
| lmp_adroit (double)   |    45.7   | Adroit        |    14    | 1               |   14        | 0     |
| lmp_adroitGPU (mixed) |    28.2   | Adroit        |    4     | 1               |   4         | 1     |
| lmp_adroitGPU (mixed) |    26.1   | Adroit        |   14     | 1               |   14        | 1     |
| lmp_adroitGPU (mixed) |    15.8   | Adroit        |   14     | 1               |   14        | 2     |
| lmp_adroitGPU (mixed) |    13.0   | Adroit        |   14     | 1               |   14        | 4     |
___

```
[lmp_gcc_openmpi] module load openmpi/gcc/1.10.2/64; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=gcc_openmpi -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=no -D CMAKE_CXX_FLAGS_RELEASE=-O2 -D PKG_MOLECULE=yes ../cmake
[lmp_skylake] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=skylake -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xSKYLAKE-AVX512" -D PKG_MOLECULE=yes ../cmake
[lmp_skylake_debug] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=skylake_debug -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-O0 -g" -D PKG_MOLECULE=yes ../cmake
[lmp_skylake_omp] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=skylake_omp -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xCORE-AVX512" -D PKG_MOLECULE=yes -D PKG_USER-OMP=yes ../cmake
[lmp_skylake_no_avx] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=skylake_no_avx -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast" -D PKG_MOLECULE=yes ../cmake
[lmp_skylake_ipo module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=skylake_ipo -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xSKYLAKE-AVX512 -ipo" -D PKG_MOLECULE=yes ../cmake
[lmp_della_intel] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=della_intel -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE=-Ofast -D PKG_MOLECULE=yes -D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake
[lmp_skylake_omp_intel] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=skylake_omp_intel -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xSKYLAKE-AVX512" -D PKG_MOLECULE=yes -D PKG_USER-OMP=yes -D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake
[lmp_skylake_opt] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=skylake_opt -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xSKYLAKE-AVX512" -D PKG_MOLECULE=yes -D PKG_OPT=yes ../cmake
[lmp_skylake_ax3] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=skylake_ax3 -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=no -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHASWELL -axBROADWELL,SKYLAKE-AVX512" -D PKG_MOLECULE=yes ../cmake
[lmp_gpu] module load intel intel-mpi cudatoolkit; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=gpu -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG -xHost" -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -xHost" -D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=mixed -D GPU_ARCH=sm_60 -D CUDPP_OPT=yes ../cmake
[lmp_tigercpu] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tigercpu -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=no -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost" -D PKG_MOLECULE=yes ../cmake
[lmp_tigercpu_omp] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tigercpu_omp -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost" -D PKG_MOLECULE=yes -D PKG_USER-OMP=yes ../cmake
[lmp_tigercpu_opt] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tigercpu_opt -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=no -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost" -D PKG_MOLECULE=yes -D PKG_OPT=yes ../cmake
[lmp_tigercpu_omp_opt] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tigercpu_omp_opt -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost" -D PKG_MOLECULE=yes -D PKG_OPT=yes -D PKG_USER-OMP=yes ../cmake
[lmp_tigercpu_intel] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tigercpu_intel -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=no -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost" -D PKG_MOLECULE=yes -D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake
[lmp_tigercpu_omp_intel] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tigercpu_omp_intel -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost" -D PKG_MOLECULE=yes -D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads -D PKG_USER-OMP=yes ../cmake
```

| build                 | time (s)  | cluster       |  ntasks  |  threads  |  GPU  |
|:----------------------|----------:| -------------:|---------:|-----------|-------|
| lmp_gcc_openmpi       |   49.1    | della-skylake |  16      | 1         | no    |
| lmp_skylake           |   41.5    | della-skylake |  16      | 1         | no    |
| lmp_skylake_no_avx    |   42.5    | della-skylake |  16      | 1         | no    |
| lmp_skylake_omp       |   33.1    | della-skylake |  16      | 1         | no    |
| lmp_skylake_omp       |   39.4    | della-skylake |  8       | 2         | no    |
| lmp_skylake_omp       |   48.9    | della-skylake |  4       | 4         | no    |
| lmp_skylake_debug     |  124.3    | della-skylake |  16      | 1         | no    |
| lmp_skylake_ipo       |   40.0    | della-skylake |  16      | 1         | no    |
| lmp_della_intel (newton off)      |   23.9    | della-sky/broad |  16      | 1         | no    |
| lmp_skylake_omp_intel |   24.9    | della-skylake |  16      | 1         | no    |
| lmp_skylake_opt       |   33.3    | della-skylake |  16      | 1         | no    |
| lmp_skylake_ax3       |   43.5    | della-skylake |  16      | 1         | no    |
| lmp_skylake_ax3       |   44.0    | della-broadwell |  16      | 1         | no    |
| lmp_skylake_ax3       |   43.1    | della-haswell |  16      | 1         | no    |
| lmp_gpu               |   76.2    | tigerGpu      |  1       | 1         | 1    |
| lmp_gpu               |   30.1    | tigerGpu      |  4       | 1         | 1    |
| lmp_gpu               |   21.3    | tigerGpu      |  8       | 1         | 1    |
| lmp_gpu               |   20.9    | tigerGpu      | 14       | 1         | 1    |
| lmp_tigercpu          |   40.8    | tigerCpu      | 16       | 1         | 1    |
| lmp_tigercpu_omp      |   33.5    | tigerCpu      | 16       | 1         | 1    |
| lmp_tigercpu_opt      |   33.7    | tigerCpu      | 16       | 1         | 1    |
| lmp_tigercpu_omp_opt  |   35.1    | tigerCpu      | 16       | 1         | 1    |
| lmp_tigercpu_intel    |   22.6    | tigerCpu      | 16       | 1         | 1    |
| lmp_tigercpu_omp_intel|   23.0    | tigerCpu      | 16       | 1         | 1    |


| build                  | size (bytes) | passed tests|
|:-----------------------|-------------:|-------------|
| lmp_gcc_openmpi        | 5194288      | no          |
| lmp_skylake_debug      | 17123992     | yes         |
| lmp_skylake_omp        | 9033192      | no          |
| lmp_skylake            | 7738016      | yes         |
| lmp_skylake_no_avx     | 7647576      | yes         |
| lmp_skylake_ipo        | 7831224      | yes         |
| lmp_della_intel        | 10979280     | yes         |
| lmp_skylake_omp_intel  | 13819856     | no          |
| lmp_skylake_opt        | 7778696      | no          |
| lmp_skylake_ax3        | 11506568     | yes         |
| lmp_gpu                | 45082560     | yes         |
| lmp_tigercpu           | 7789872      | yes         |
| lmp_tigercpu_omp       | 9033224      | yes         |
| lmp_tigercpu_opt       | 7830112      | yes         |
| lmp_tigercpu_omp_opt   | 9073672      | yes         |
| lmp_tigercpu_intel     | 11869248     | yes         |
| lmp_tigercpu_omp_intel | 13819888     | yes         |


### 2. Polymer melt

N=160000 (200 polymers, 800 monomers per polymer), KG bead-spring model, T=1, rho=0.85, rc=2^(1/6)

```
# bead-spring polymer melt benchmark

units		  lj
atom_style	  angle
special_bonds     fene

read_data	  ../lammps.start

mass		  1 1.0
velocity          all create 1.0 87287

neighbor	  0.4 bin
neigh_modify	  every 1 delay 1

pair_style	  lj/cut 1.12246205
pair_modify	  shift yes
pair_coeff	  1 1 1.0 1.0 1.12246205

bond_style        fene
bond_coeff	  1 30.0 1.5 1.0 1.0

angle_style       cosine
angle_coeff       1 1.5

fix		  1 all nve
fix		  2 all langevin 1.0 1.0 1.0 904297

thermo            5000
timestep	  0.01

run		  25000
```

| build                 | time (s)  | cluster       |  ntasks  |  threads  |  GPU  |
|:----------------------|----------:| -------------:|---------:|-----------|-------|
| lmp_tigercpu          |  83.6    | tigerCpu      |  16       | 1         | no    |
| lmp_tigercpu          |  41.1    | tigerCpu      |  32       | 1         | no    |
| lmp_tigercpu          |  22.2    | tigerCpu      |  64       | 1         | no    |
| lmp_tigercpu_intel    |  48.3    | tigerCpu      |  32       | 1         | no    |
| lmp_tigercpu_intel    |  24.5    | tigerCpu      |  64       | 1         | no    |
| lmp_tgrgpu_omp        |  39.8    | tigerCpu      |  32       | 1         | 1    |
| lmp_tgrgpu_omp        |  21.2    | tigerCpu      |  64       | 1         | 1    |
| lmp_tgrgpu            |  118.6   | tigerGpu      |  8        | 1         | 1    |
| lmp_tgrgpu            |  109.9   | tigerGpu      |  14       | 1         | 1    |


### 3. Solvated peptide

N=128256, Water, SHAKE, PPPM, T=275 K

```
# Solvated 5-mer peptide

units		real
atom_style	full

pair_style	lj/charmm/coul/long 8.0 10.0 10.0
bond_style      harmonic
angle_style     charmm
dihedral_style  charmm
improper_style  harmonic
kspace_style	pppm 0.0001

read_data	../data.peptide

replicate       5 5 5 # new line

neighbor	2.0 bin
neigh_modify	delay 5

timestep	2.0

thermo_style	multi
thermo		500

fix		1 all nvt temp 275.0 275.0 100.0 tchain 1
fix		2 all shake 0.0001 10 100 b 4 6 8 10 12 14 18 a 31

group		peptide type <= 12

run	        1000
```

```
[lmp_tgrcpu] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tgrcpu -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost" -D FFT=MKL -D PKG_MOLECULE=yes -D PKG_RIGID=yes -D PKG_KSPACE=yes ../cmake
[lmp_tgrcpu_omp] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tgrcpu_omp -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost" -D FFT=MKL -D PKG_MOLECULE=yes -D PKG_RIGID=yes -D PKG_KSPACE=yes -D PKG_USER-OMP=yes ../cmake
[lmp_tgrcpu_intel] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tgrcpu_intel -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE=-Ofast -D FFT=MKL -D PKG_MOLECULE=yes -D PKG_RIGID=yes -D PKG_KSPACE=yes -D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake
[lmp_tgrcpu_opt] module load intel intel-mpi; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tgrcpu_opt -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost" -D FFT=MKL -D PKG_MOLECULE=yes -D PKG_RIGID=yes -D PKG_KSPACE=yes -D PKG_OPT=yes ../cmake
[lmp_tgrgpu] module load intel intel-mpi cudatoolkit; cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=tgrgpu -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost" -D FFT=MKL -D PKG_MOLECULE=yes -D PKG_RIGID=yes -D PKG_KSPACE=yes -D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=mixed -D GPU_ARCH=sm_60 -D CUDPP_OPT=yes ../cmake
```

| build                 | time (s)  | cluster       |  ntasks  |  threads  |  GPU  |
|:----------------------|----------:| -------------:|---------:|-----------|-------|
| lmp_tgrcpu            |  150.8    | tigerCpu      |  7       | 1         | no    |
| lmp_tgrcpu            |   73.0    | tigerCpu      |  14      | 1         | no    |
| lmp_tgrcpu            |   68.3    | tigerCpu      |  14      | 2         | no    |
| lmp_tgrcpu            |   43.2    | tigerCpu      |  28      | 1         | no    |
| lmp_tgrcpu_omp        |   62.7    | tigerCpu      |  14      | 1         | no    |
| lmp_tgrcpu_omp        |   35.7    | tigerCpu      |  28      | 1         | no    |
| lmp_tgrcpu_opt        |   59.9    | tigerCpu      |  14      | 1         | no    |
| lmp_tgrcpu_opt        |   35.4    | tigerCpu      |  28      | 1         | no    |
| lmp_tgrgpu            |   48.9    | tigerGpu      |  1       | 1         | 1     |
| lmp_tgrgpu            |   15.1    | tigerGpu      |  7       | 1         | 1     |
| lmp_tgrgpu            |   19.0    | tigerGpu      |  14      | 1         | 1     |
| lmp_tgrgpu            |   13.8    | tigerGpu      |  7       | 1         | 2     |

For 2 gpu's use: lmp_tgrgpu -sf gpu -pk gpu 2 -in in.peptide.modified


| build                  | size (bytes) | passed tests|
|:-----------------------|-------------:|-------------|
| lmp_tgrcpu        | 9899112       | yes          |
| lmp_tgrcpu_omp    | 14261528      | yes          |
| lmp_tgrcpu_intel  | 16849752      | yes          |
| lmp_tgrcpu_opt    | 10538976      | yes          |
| lmp_tgrgpu        | 48683056      | yes          |

```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=7
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --mem-per-cpu=4G
#SBATCH --gres=gpu:2

module load intel intel-mpi
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
 
srun $HOME/.local/bin/lmp_tgrgpu -sf gpu -pk gpu 2 -in ../in.peptide.modified
```
