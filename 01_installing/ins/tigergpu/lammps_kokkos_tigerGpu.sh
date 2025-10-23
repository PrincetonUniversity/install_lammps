#!/bin/bash

VERSION=22Jul2025
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load fftw/gcc/3.3.10
module load openmpi/gcc/4.1.8
module load cudatoolkit/12.9

cmake3 \
    -D CMAKE_INSTALL_PREFIX=$HOME/.local \
    -D CMAKE_BUILD_TYPE=Release \
    -D LAMMPS_MACHINE=gpu_kokkos \
    -D ENABLE_TESTING=no \
    -D BUILD_OMP=yes \
    -D BUILD_MPI=yes \
    -D PKG_MOLECULE=yes \
    -D PKG_RIGID=yes \
    -D PKG_KSPACE=yes -D FFT=FFTW3 -D FFT_SINGLE=yes \
    -D FFTW3F_INCLUDE_DIR=${FFTW3DIR}/include \
    -D FFTW3F_LIBRARY=${FFTW3DIR}/lib64/libfftw3f.so \
    -D PKG_KOKKOS=yes \
    -D FFT_KOKKOS=CUFFT \
    -D Kokkos_ARCH_HOPPER90=yes \
    -D Kokkos_ENABLE_CUDA=yes \
    -D Kokkos_ENABLE_OPENMP=yes \
    -D CMAKE_CXX_COMPILER=$HOME/software/lammps-stable_22Jul2025/lib/kokkos/bin/nvcc_wrapper \
    ../cmake

make -j 16
make install
