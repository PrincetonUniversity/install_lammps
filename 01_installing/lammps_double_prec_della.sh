#!/bin/bash

# build a double precision version of lammps for della

VERSION=29Oct2020
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build
cd build

module purge
module load intel/19.0/64/19.0.5.281 intel-mpi/intel/2018.3/64

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=della_double -D ENABLE_TESTING=yes \
-D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_CXX_COMPILER=icpc -D CMAKE_BUILD_TYPE=Release \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xCORE-AVX2 -axCORE-AVX512 -DNDEBUG" \
-D PKG_USER-OMP=yes -D PKG_MOLECULE=yes ../cmake

make -j 10
make test
make install
