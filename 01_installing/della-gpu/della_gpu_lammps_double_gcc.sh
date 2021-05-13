#!/bin/bash

# this will produce a double precision build
# adding -Ofast or -march=native will cause tests to fail
# do not include the cmake module in your Slurm script

VERSION=29Oct2020
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load cmake/3.18.2
module load fftw/gcc/3.3.9
module load openmpi/gcc/4.1.0
module load cudatoolkit/11.3

cmake -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D CMAKE_BUILD_TYPE=Release \
-D LAMMPS_MACHINE=della_gpu_gcc \
-D ENABLE_TESTING=yes \
-D BUILD_OMP=yes \
-D BUILD_MPI=yes \
-D CMAKE_C_COMPILER=gcc \
-D CMAKE_CXX_COMPILER=g++ \
-D CMAKE_CXX_FLAGS_RELEASE="-O3 -fopenmp -DNDEBUG" \
-D CMAKE_Fortran_COMPILER=/usr/bin/gfortran \
-D PKG_MOLECULE=yes -D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=FFTW3 -D FFT_SINGLE=no \
-D FFTW3_INCLUDE_DIR=${FFTW3DIR}/include \
-D FFTW3_LIBRARY=${FFTW3DIR}/lib64/libfftw3.so \
-D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=double -D GPU_ARCH=sm_80 -D CUDPP_OPT=no ../cmake

make -j 16
make test
make install
