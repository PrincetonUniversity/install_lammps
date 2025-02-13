#!/bin/bash

VERSION=29Aug2024
#wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load gcc-toolset/13
module load openmpi/gcc/4.1.2
module load cudatoolkit/12.8

cmake3 \
    -D CMAKE_INSTALL_PREFIX=$HOME/.local \
    -D CMAKE_BUILD_TYPE=Release \
    -D LAMMPS_MACHINE=della_gpu_kokkos \
    -D ENABLE_TESTING=no \
    -D BUILD_OMP=yes \
    -D BUILD_MPI=yes \
    -D PKG_MOLECULE=yes \
    -D PKG_RIGID=yes \
    -D PKG_KOKKOS=yes \
    -D PKG_KSPACE=yes -D FFT_KOKKOS=CUFFT -D FFT_SINGLE=yes \
    -D Kokkos_ARCH_AMPERE80=yes \
    -D Kokkos_ENABLE_CUDA=yes \
    -D Kokkos_ENABLE_OPENMP=yes \
    -D CMAKE_CXX_COMPILER=$HOME/software/lmp_hess/lammps-stable_29Aug2024/lib/kokkos/bin/nvcc_wrapper \
    ../cmake

make -j 8
make install
