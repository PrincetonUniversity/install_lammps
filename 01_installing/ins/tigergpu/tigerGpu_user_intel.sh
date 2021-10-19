#!/bin/bash

VERSION=29Sep2021
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxvf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

# include the modules below in your Slurm script
module purge
module load intel/19.1/64/19.1.1.217
module load intel-mpi/intel/2019.7/64
module load cudatoolkit/11.3

# add or remove packages if needed
cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D CMAKE_BUILD_TYPE=Release \
-D LAMMPS_MACHINE=tigerGpu \
-D ENABLE_TESTING=no \
-D BUILD_MPI=yes \
-D BUILD_OMP=yes \
-D CMAKE_C_COMPILER=icc \
-D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost -DNDEBUG" \
-D PKG_MOLECULE=yes \
-D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=yes \
-D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=mixed -D GPU_ARCH=sm_60 -D CUDPP_OPT=no \
-D PKG_INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake

make -j 10
make install
