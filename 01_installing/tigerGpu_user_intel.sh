#!/bin/bash

wget https://github.com/lammps/lammps/archive/patch_4Feb2020.tar.gz
tar zxf patch_4Feb2020.tar.gz
cd lammps-patch_4Feb2020
mkdir build && cd build

module purge
module load intel/18.0/64/18.0.3.222
module load intel-mpi/intel/2018.3/64
module load cudatoolkit/10.2

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=tigerGpu \
-D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc \
-D CMAKE_CXX_COMPILER=icpc -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -mtune=broadwell -DNDEBUG" \
-D PKG_USER-OMP=yes -D PKG_MOLECULE=yes -D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=yes \
-D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=mixed -D GPU_ARCH=sm_60 -D CUDPP_OPT=yes \
-D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake

make -j 10
make test
make install
