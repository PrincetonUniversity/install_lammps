#!/bin/bash

version=3Mar2020

wget https://github.com/lammps/lammps/archive/stable_${version}.tar.gz
tar zxvf stable_${version}.tar.gz
cd lammps-stable_${version}
mkdir build
cd build

# need to edit lammps-stable_3Mar2020/cmake/Modules/Packages/GPU.cmake

module purge
module load openmpi/gcc/4.0.4/64 cudatoolkit/11.0

# copy and paste the next 5 lines into the terminal
cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D CMAKE_BUILD_TYPE=Release -D LAMMPS_MACHINE=traverse \
-D ENABLE_TESTING=yes -D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_C_COMPILER=gcc \
-D CMAKE_CXX_COMPILER=g++ -D CMAKE_CXX_FLAGS_RELEASE="-Ofast -mcpu=power9 -mtune=power9 -mvsx" \
-D PKG_USER-OMP=yes -D PKG_MOLECULE=yes \
-D PKG_GPU=yes -D GPU_API=cuda -D GPU_PREC=mixed -D GPU_ARCH=sm_70 -D CUDPP_OPT=yes ../cmake

make -j 10
make test
make install
