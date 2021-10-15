#!/bin/bash

# build a mixed-precision version of lammps for della with the user-intel and user-reaction packages

VERSION=29Oct2020
wget https://github.com/lammps/lammps/archive/refs/tags/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load intel/18.0/64/18.0.3.222 intel-mpi/intel/2018.3/64

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=della_rxn -D ENABLE_TESTING=yes \
-D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc -D CMAKE_BUILD_TYPE=Release \
-D CMAKE_Fortran_COMPILER=/opt/intel/compilers_and_libraries_2018.3.222/linux/bin/intel64/ifort \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -axCORE-AVX512 -DNDEBUG" \
-D PKG_USER-REACTION=yes -D PKG_MOLECULE=yes \
-D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake

make -j 10
#make test
make install

# if you uncomment "make test" you will find:
# 90% tests passed, 34 tests failed out of 355

# looking at lammps-stable_29Oct2020/build/Testing/Temporary/LastTest.log
# one can see that the failures can be ignored since they relate to
# slight differences in the calculated vs. expected values, for example:
# ~/software/lammps-stable_29Oct2020/unittest/force-styles/test_fix_timestep.cpp:339: Failure
# Expected: (err) <= (epsilon)
#   Actual: 1.0039224370814478e-14 vs 1e-14
