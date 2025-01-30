#!/bin/bash

VERSION=29Aug2024
wget https://github.com/lammps/lammps/archive/refs/tags/stable_${VERSION}.tar.gz
tar zvxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load aocl/gcc/5.0.0
module load openmpi/gcc/4.1.6
FFTW3DIR=/opt/AMD/aocl/aocl-linux-gcc-5.0.0/gcc

cmake3 \
    -D CMAKE_INSTALL_PREFIX=$HOME/.local \
    -D LAMMPS_MACHINE=double_gcc \
    -D ENABLE_TESTING=no \
    -D BUILD_MPI=yes \
    -D BUILD_OMP=yes \
    -D CMAKE_CXX_COMPILER=g++ \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -march=native -DNDEBUG" \
    -D PKG_KSPACE=yes \
    -D FFT=FFTW3 \
    -D FFT_SINGLE=no \
    -D FFTW3_INCLUDE_DIR=${FFTW3DIR}/include_LP64 \
    -D FFTW3_LIBRARY=${FFTW3DIR}/lib_LP64/libfftw3.so \
    -D PKG_OPENMP=yes \
    -D PKG_MOLECULE=yes \
    -D PKG_RIGID=yes \
    ../cmake

make -j 8
make install
