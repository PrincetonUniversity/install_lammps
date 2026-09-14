!/bin/bash

VERSION=22Jul2025
wget https://github.com/lammps/lammps/archive/refs/tags/stable_${VERSION}.tar.gz
tar zvxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load aocc/5.2.0
module load aocl/aocc/ST/5.3.0
module load openmpi/aocc-5.2.0/5.0.10

cmake3 \
    -D CMAKE_INSTALL_PREFIX=$HOME/.local \
    -D LAMMPS_MACHINE=cpu \
    -D ENABLE_TESTING=no \
    -D BUILD_MPI=yes \
    -D BUILD_OMP=yes \
    -D CMAKE_CXX_COMPILER=clang++ \
    -D CMAKE_C_COMPILER=clang \
    -D CMAKE_Fortran_COMPILER=flang \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -march=native -DNDEBUG" \
    -D PKG_KSPACE=yes \
    -D FFT=FFTW3 \
    -D FFT_SINGLE=no \
    -D PKG_MOLECULE=yes \
    -D PKG_RIGID=yes \
    ../cmake

make -j 8
make install
