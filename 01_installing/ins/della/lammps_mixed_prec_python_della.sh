#!/bin/bash

# build a mixed precision version of lammps for della using the user-intel
# and python packages

VERSION=2Aug2023
wget https://github.com/lammps/lammps/archive/stable_${VERSION}.tar.gz
#rm -rf lammps-stable_${VERSION}
tar zxf stable_${VERSION}.tar.gz
cd lammps-stable_${VERSION}
mkdir build && cd build

module purge
module load intel/2022.2
module load intel-mpi/intel/2021.7.0

# create a conda environment with mpi4py
module load anaconda3/2023.9
conda activate lammps-env
#conda remove --name lammps-env --all -y -q
conda create --name lammps-env python=3.8 -y
conda activate lammps-env
export MPICC=$(which mpicc)
echo $MPICC
pip install mpi4py --no-cache-dir

cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local \
-D ENABLE_TESTING=no \
-D BUILD_MPI=yes \
-D BUILD_OMP=yes \
-D CMAKE_CXX_COMPILER=icpx \
-D CMAKE_BUILD_TYPE=Release \
-D CMAKE_CXX_FLAGS_RELEASE="-Ofast -xHost -qopenmp -DNDEBUG" \
-D BUILD_SHARED_LIBS=yes \
-D PKG_PYTHON=yes \
-D PYTHON_EXECUTABLE=$HOME/.conda/envs/lammps-env/bin/python3.8 \
-D PKG_MOLECULE=yes \
-D PKG_RIGID=yes \
-D PKG_KSPACE=yes \
-D FFT=MKL -D FFT_SINGLE=yes \
-D PKG_INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake
#-D LAMMPS_MACHINE=dellapy \

cmake3 --build . -j 4
cmake3 --install .

make install-python
