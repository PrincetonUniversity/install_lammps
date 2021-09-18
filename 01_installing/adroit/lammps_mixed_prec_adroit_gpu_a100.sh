#!/bin/bash

# build mixed-precision version with user-intel for the A100 GPU node

VERSION=29Oct2020
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

# include the modules below in your Slurm scipt
module purge
module load intel/19.1.1.217 intel-mpi/intel/2019.7
module load cudatoolkit/11.4

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release \
-D LAMMPS_MACHINE=adroitGPU -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes \
-D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc \
-D CMAKE_Fortran_COMPILER=/opt/intel/compilers_and_libraries_2020.1.217/linux/bin/intel64/ifort \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost -DNDEBUG" -D PKG_USER-OMP=yes \
-D PKG_MOLECULE=yes -D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=yes \
-D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=mixed -D GPU_ARCH=sm_80 -D CUDPP_OPT=yes \
-D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake

make -j 4
#make test
make install
