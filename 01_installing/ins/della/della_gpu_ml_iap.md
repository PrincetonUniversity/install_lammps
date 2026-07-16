# ML-IAP on Della (GPU)

This page shows to compile LAMMPS with kokkos support on Della _and_ with support for the popular [ML-IAP](https://docs.lammps.org/Build_extras.html#mliap) package for machine learning interatomic potentials.

Instructions:

1. `bash python_prep.sh` --> this will make the necessary Python environment that will be linked to LAMMPS
2. `bash install.sh` --> this will compile LAMMPS with the ML-IAP package and install it in the corresponding Python environment

Notes:
- In practice, you should probably not be installing all this stuff in `$HOME` and should put it somewhere like a `/scratch/gpfs` directory.
- Any machine learning interatomic potential (MLIP) you want to use will need to be installed in the custom Python environment.

`python_prep.sh`:
```
PYENV=$HOME/software/lammps/pyenv
module load anaconda3/2025.12
conda create -y -p ${PYENV} python=3.13
conda activate ${PYENV}
pip install uv
uv pip install -r requirements.txt
```

`requirements.txt`
```
numpy>2.0.0
mpi4py
cython
cuequivariance-torch
cuequivariance
cuequivariance-ops-torch-cu13
cupy-cuda13x
```

`install.sh`:
```
#!/bin/bash

# build lammps with MPI for A100 GPUs (sm_80)
VERSION=patch_4Jul2026
BASE_PATH=$(pwd)
INSTALL_PREFIX=${BASE_PATH}/${VERSION}

# Make Python env
PYENV=${BASE_PATH}/pyenv
if [ ! -x "${PYENV}/bin/python3" ]; then
    echo "ERROR: ${PYENV} not found or missing python3." >&2
    echo "Create it first with bash python_prep.sh" >&2
    exit 1
fi

conda activate ${PYENV}
mkdir -p ${BASE_PATH}/lammps_github
cd ${BASE_PATH}/lammps_github

# Download LAMMPS
wget https://github.com/lammps/lammps/archive/${VERSION}.tar.gz
tar -xzvf ${VERSION}.tar.gz
cd lammps-${VERSION}
mkdir build && cd build

module purge
module load gcc-toolset/14
module load openmpi/gcc/4.1.8
module load cudatoolkit/13.3

cmake \
    -D CMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -D CMAKE_BUILD_TYPE=Release \
    -D ENABLE_TESTING=no \
    -D BUILD_OMP=yes \
    -D BUILD_MPI=yes \
    -D PKG_MOLECULE=yes \
    -D PKG_RIGID=yes \
    -D PKG_KOKKOS=yes \
    -D PKG_KSPACE=yes -D FFT_KOKKOS=CUFFT -D FFT_SINGLE=yes \
    -D Kokkos_ARCH_AMPERE80=yes \
    -D Kokkos_ENABLE_CUDA=yes \
    -D Kokkos_ENABLE_OPENMP=yes \
    -D CMAKE_CXX_COMPILER=$(pwd)/../lib/kokkos/bin/nvcc_wrapper \
    -D PKG_ML-SNAP=yes \
    -D PKG_ML-IAP=yes \
    -D PKG_ML-PACE=yes \
    -D PKG_ML-MACE=yes \
    -D PKG_MPIIO=yes \
    -D MLIAP_ENABLE_PYTHON=yes \
    -D PKG_PYTHON=yes \
    -D BUILD_LIB=yes \
    -D BUILD_SHARED_LIBS=yes \
    -D LAMMPS_EXCEPTIONS=yes \
    ../cmake

make -j 8
make install
make install-python
chmod -R a+rX "${INSTALL_PREFIX}"
```

And here is a representative module file:

```
#%Module1.0
set name "lammps"
set version "patch_4Jul2026"
set software "$HOME/software"
set prefix "$software/$name/$version"

module-whatis "Name        : $name"
module-whatis "Version     : $version"

# Executables and scripts
prepend-path PATH "$prefix/bin"
prepend-path LAMMPS_PYENV "$software/$name/pyenv"
prepend-path LD_LIBRARY_PATH "$software/$name/$version/lib64"
prepend-path LD_LIBRARY_PATH "$software/$name/pyenv/lib"

# Modules used for compilation
module load gcc-toolset/14
module load openmpi/gcc/4.1.8
module load cudatoolkit/13.3
```

Usage with the above modulefile:

```
module load lammps/patch_4Jul2026
module load anaconda3/2025.12
conda activate $LAMMPS_PYENV
lmp -i <NameOfInput.in>
```
