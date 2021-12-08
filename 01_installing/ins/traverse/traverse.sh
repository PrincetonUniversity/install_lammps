#!/bin/bash

VERSION=29Sep2021
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxvf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load openmpi/gcc/4.1.1/64
module load fftw/gcc/3.3.8
module load cudatoolkit/11.4

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D LAMMPS_MACHINE=traverse \
-D BUILD_MPI=yes \
-D BUILD_OMP=yes \
-D CMAKE_BUILD_TYPE=Release \
-D CMAKE_C_COMPILER=gcc \
-D CMAKE_CXX_COMPILER=g++ \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -mcpu=power9 -mtune=power9" \
-D ENABLE_TESTING=no \
-D PKG_KSPACE=yes -D FFT=FFTW3 -D FFT_SINGLE=yes \
-D FFTW3_INCLUDE_DIR=${FFTW3DIR}/include \
-D FFTW3_LIBRARY=${FFTW3DIR}/lib64/libfftw3f.so \
-D PKG_MOLECULE=yes \
-D PKG_RIGID=yes \
-D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=mixed -D GPU_ARCH=sm_70 ../cmake

make -j 10
make install
