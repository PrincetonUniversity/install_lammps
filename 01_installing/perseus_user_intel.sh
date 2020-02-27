#!/bin/bash

wget https://github.com/lammps/lammps/archive/patch_4Feb2020.tar.gz
tar -zxvf patch_4Feb2020.tar.gz 
cd lammps-patch_4Feb2020
mkdir build && cd build

module purge
module load intel/18.0/64/18.0.3.222
module load intel-mpi/intel/2018.3/64

# below the resulting executable is set to be lmp_perseus (you may want to rename it)

# copy and paste the following into the terminal
cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=perseus -D ENABLE_TESTING=yes \
-D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_CXX_COMPILER=icpc -D CMAKE_BUILD_TYPE=Release \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -mtune=broadwell -DNDEBUG" \
-D PKG_USER-OMP=yes -D PKG_MOLECULE=yes -D PKG_RIGID=yes -D PKG_MISC=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=yes \
-D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake

make -j 10
make test
make install
