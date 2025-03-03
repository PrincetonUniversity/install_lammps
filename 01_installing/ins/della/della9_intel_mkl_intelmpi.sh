#!/bin/bash

VERSION=29Aug2024
wget https://github.com/lammps/lammps/archive/refs/tags/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load intel-oneapi/2024.2
module load intel-mpi/oneapi/2021.13
module load intel-mkl/2024.2

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D LAMMPS_MACHINE=d9_intel_mkl \
-D ENABLE_TESTING=no \
-D BUILD_MPI=yes \
-D BUILD_OMP=yes \
-D CMAKE_BUILD_TYPE=Release \
-D CMAKE_CXX_COMPILER=icpx \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -axCORE-AVX512 -qopenmp -DNDEBUG" \
-D PKG_MOLECULE=yes \
-D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=yes  ../cmake

make -j 10
make install
