#!/bin/bash

module purge
module load intel/2021.1.2
module load intel-mpi/intel/2021.1.1
module load anaconda3/2021.5
module load fftw/intel-2021.1/intel-mpi/3.3.9

#############################################################
# PLUMED
#############################################################

plumedversion=v2.8 ###Specify your PLUMED version here
git clone -b ${plumedversion} https://github.com/plumed/plumed2 plumed2-${plumedversion}
cd plumed2-${plumedversion}


#############################################################
# starting build of plumed
#############################################################

./configure --prefix=$HOME/.local --enable-modules=all CXX=mpiicpc CXXFLAGS="-Ofast -axCORE-AVX512"

make -j 14
make install

# build a mixed-precision version of lammps for della (cpu) using the user-intel package
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$HOME/.local/lib/pkgconfig/"
VERSION=29Sep2021 ###Specify your LAMMPS version here (Some package names change after Aug2019 version)
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
tar zxvf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build
cd build

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D LAMMPS_MACHINE=della_cvhd  \
-D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_CXX_COMPILER=icpc -D CMAKE_BUILD_TYPE=Release \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -axCORE-AVX512 -DNDEBUG" \
-D PKG_KSPACE=yes -D PKG_RIGID=yes -D PKG_MANYBODY=yes \
-D PKG_OMP=yes -D PKG_MOLECULE=yes -D PKG_INTEL=yes -D INTEL_ARCH=cpu \
-D PKG_EXTRA-FIX=yes -D PKG_EXTRA-DUMP=yes \
-D PKG_PLUMED=yes -D DOWNLOAD_PLUMED=no -D PLUMED_MODE=static \
-D INTEL_LRT_MODE=threads ../cmake

make -j 14
make install
