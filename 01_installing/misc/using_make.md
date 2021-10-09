# Using make

The procedure below can be used to build LAMMPS with USER-INTEL using make instead cmake. This provides more control over the build. It makes an executable with AVX512 instructions and is not specific to Cascade Lake processors.

```
wget https://github.com/lammps/lammps/archive/stable_3Mar2020.tar.gz
tar zxf stable_3Mar2020.tar.gz
cd lammps-stable_3Mar2020/
cd src
make ps
make yes-user-intel
make yes-kspace
make yes-rigid
make yes-user-omp
make yes-molecule
make yes-misc
module load intel/19.1/64/19.1.1.217 intel-mpi/intel/2019.7/64
mkdir -p MAKE/MINE
cd MAKE/MINE
wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/Makefile.cascade
cd ../..
make cascade
```
