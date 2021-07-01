#!/bin/bash

# build mixed-precision version with user-intel with V100 GPU acceleration

VERSION=29Oct2020
#wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load intel/19.0/64/19.0.5.281 intel-mpi/intel/2018.3/64
module load cudatoolkit/10.2

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release \
-D LAMMPS_MACHINE=adroitGPU -D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes \
-D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc \
-D CMAKE_Fortran_COMPILER=/opt/intel/compilers_and_libraries_2019.5.281/linux/bin/intel64/ifort \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -mtune=skylake -DNDEBUG" -D PKG_USER-OMP=yes \
-D PKG_MOLECULE=yes -D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=yes \
-D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=mixed -D GPU_ARCH=sm_70 -D CUDPP_OPT=yes \
-D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake

make -j 4
#make test
make install

# if you uncomment "make test" you will find:
# 63% tests passed, 125 tests failed out of 340

# looking at lammps-stable_29Oct2020/build/Testing/Temporary/LastTest.log
# one can see that the failures seem to arise because the tests do not
# account for the single precision calculations of user-intel

# one could write to the lammps mailing list to be sure
