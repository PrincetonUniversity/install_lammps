# VMD Plugins

Below is a procedure for using the `dump` command with the `molfile` style (be sure to replace `<YourNetID>` twice): 

```
mkdir -p software/vmd_precompiled
cd software/vmd_precompiled
wget --no-check-certificate https://www.ks.uiuc.edu/Research/vmd/vmd-1.9.3/files/final/vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz
tar zxf vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz
```

Next build LAMMPS:

```
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
-D MOLFILE_INCLUDE_DIRS=/home/<YourNetID>/software/vmd_precompiled/vmd-1.9.3/plugins/include -D PKG_USER-MOLFILE=yes \
-D PKG_USER-INTEL=yes -D INTEL_ARCH=cpu -D INTEL_LRT_MODE=threads ../cmake

make -j 10
make test
make install
```

Finally, run a test:

```
units           lj
atom_style      atomic

lattice         fcc 0.8442
region          box block 0 30 0 30 0 30
create_box      1 box
create_atoms    1 box
mass            1 1.0

velocity        all create 1.0 87287

pair_style      lj/cut 2.5
pair_coeff      1 1 1.0 1.0 2.5

neighbor        0.3 bin
neigh_modify    every 20 delay 0 check no

fix             1 all nve
fix             2 all langevin 1.0 1.0 1.0 48279

dump            mf1 all molfile 100 melt-*.pdb pdb /home/<YourNetID>/software/vmd_precompiled/vmd-1.9.3/plugins/LINUXAMD64/molfile

timestep        0.005

thermo          500
run             1000
```
