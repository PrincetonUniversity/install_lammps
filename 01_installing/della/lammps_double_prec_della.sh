#!/bin/bash

# build a double-precision version of lammps for della (cpu)

version=29Sep2021
wget https://github.com/lammps/lammps/archive/stable_${version}.tar.gz
tar zxvf stable_${version}.tar.gz
cd lammps-stable_${version}
mkdir build && cd build

module purge
module load intel/19.1/64/19.1.1.217
module load intel-mpi/intel/2019.7/64

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D LAMMPS_MACHINE=della_double \
-D ENABLE_TESTING=no \
-D BUILD_MPI=yes \
-D BUILD_OMP=yes \
-D CMAKE_BUILD_TYPE=Release \
-D CMAKE_CXX_COMPILER=icpc \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost -axCORE-AVX512 -qopenmp -restrict -DNDEBUG" \
-D PKG_MOLECULE=yes \
-D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=no  ../cmake

make -j 10
make install
