#!/bin/bash

# build a mixed precision version of lammps for della using the user-intel
# and python packages

VERSION=4Feb2020
wget https://github.com/lammps/lammps/archive/patch_${VERSION}.tar.gz
tar zxf patch_${VERSION}.tar.gz
cd lammps-patch_${VERSION}
mkdir build
cd build

module purge
module load intel/18.0/64/18.0.3.222
module load intel-mpi/intel/2018.3/64

# create a conda environment with mpi4py
module load anaconda3/2020.7
conda create --name lammps-env python=3.8 -y
conda activate lammps-env
echo $MPICC
export MPICC=$(which mpicc)
echo $MPICC
pip install mpi4py

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=della -D ENABLE_TESTING=yes \
-D BUILD_MPI=yes -D BUILD_OMP=yes -D CMAKE_CXX_COMPILER=icpc -D CMAKE_BUILD_TYPE=Release \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -axCORE-AVX512 -DNDEBUG" \
-D BUILD_LIB=on -D BUILD_SHARED_LIBS=on -D LAMMPS_EXCEPTIONS=on -D PKG_PYTHON=on \
-D PYTHON_EXECUTABLE=$HOME/.conda/envs/lammps-env/bin/python3.8 \
-D PYTHON_INCLUDE_DIR=$HOME/.conda/envs/lammps-env/include/python3.8 \
-D PYTHON_LIBRARY=$HOME/.conda/envs/lammps-env/lib/libpython3.8.so \
-D PKG_USER-OMP=yes -D PKG_MOLECULE=yes -D PKG_RIGID=yes \
-D PKG_KSPACE=yes -D FFT=MKL -D FFT_SINGLE=yes \
-D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake

cmake3 --build . -j 12
cmake3 --install .
