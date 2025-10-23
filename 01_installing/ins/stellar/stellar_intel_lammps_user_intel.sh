#!/bin/bash

VERSION=22Jul2025
wget https://github.com/lammps/lammps/archive/refs/tags/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load intel-oneapi/2024.2
module load intel-mpi/oneapi/2021.13
module load intel-mkl/2024.2

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D CMAKE_BUILD_TYPE=Release \
-D LAMMPS_MACHINE=intel \
-D ENABLE_TESTING=no \
-D BUILD_OMP=yes \
-D BUILD_MPI=yes \
-D CMAKE_CXX_COMPILER=icpx \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost -qopenmp -DNDEBUG" \
-D PKG_MOLECULE=yes -D PKG_RIGID=yes -D PKG_MISC=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=yes \
-D PKG_INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake

make -j 8
make install
