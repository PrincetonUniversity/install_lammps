#!/bin/bash

VERSION=29Sep2021
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load fftw/gcc/3.3.9
module load openmpi/gcc/4.1.0
module load cudatoolkit/11.4

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D CMAKE_BUILD_TYPE=Release \
-D LAMMPS_MACHINE=della_gpu_gcc \
-D ENABLE_TESTING=no \
-D BUILD_OMP=yes \
-D BUILD_MPI=yes \
-D CMAKE_C_COMPILER=gcc \
-D CMAKE_CXX_COMPILER=g++ \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -march=native -fopenmp -DNDEBUG" \
-D PKG_MOLECULE=yes \
-D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=FFTW3 -D FFT_SINGLE=yes \
-D FFTW3F_INCLUDE_DIR=${FFTW3DIR}/include \
-D FFTW3F_LIBRARY=${FFTW3DIR}/lib64/libfftw3f.so \
-D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=mixed -D GPU_ARCH=sm_80 -D CUDPP_OPT=no ../cmake

make -j 16
make install
