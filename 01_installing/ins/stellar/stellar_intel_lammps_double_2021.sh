#!/bin/bash
  
# This bash script will build and install a double precision version of lammps
# in your home directoy on stellar-intel. Most simulations do not need double
# precision and you should build the code with the user-intel package instead
# which uses a mix of single and double precision for increased performance.

VERSION=29Oct2020
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build
cd build

module purge
module load intel/2021.1.2
module load intel-mpi/intel/2021.1.1

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=double -D ENABLE_TESTING=no \
-D CMAKE_Fortran_COMPILER=/opt/intel/oneapi/compiler/2021.1.2/linux/bin/intel64/ifort \
-D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_CXX_COMPILER=icpc -D CMAKE_BUILD_TYPE=Release \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost -DNDEBUG" \
-D PKG_USER-OMP=yes -D PKG_MOLECULE=yes -D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=no ../cmake

make -j 10
make install
