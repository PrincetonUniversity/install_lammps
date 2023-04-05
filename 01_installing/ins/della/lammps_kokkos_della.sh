#!/bin/bash

VERSION=23Jun2022
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build


module purge
module load gcc-toolset/10
module load fftw/gcc/3.3.9
module load openmpi/gcc/4.1.0
module load cudatoolkit/11.7

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D CMAKE_BUILD_TYPE=Release \
-D LAMMPS_MACHINE=della_gpu_kokkos \
-D ENABLE_TESTING=no \
-D BUILD_OMP=yes \
-D BUILD_MPI=yes \
-D PKG_MOLECULE=yes \
-D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=FFTW3 -D FFT_SINGLE=yes \
-D FFTW3F_INCLUDE_DIR=${FFTW3DIR}/include \
-D FFTW3F_LIBRARY=${FFTW3DIR}/lib64/libfftw3f.so \
-D PKG_KOKKOS=yes \
-D Kokkos_ARCH_AMPERE80=yes \
-D Kokkos_ENABLE_CUDA=yes \
-D Kokkos_ENABLE_OPENMP=yes \
-D CMAKE_CXX_COMPILER=$HOME/software/lammps-stable_23Jun2022/lib/kokkos/bin/nvcc_wrapper ../cmake

make -j 16
make install
