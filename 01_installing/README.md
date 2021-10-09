# Installing and Running LAMMPS on the HPC Clusters

Below are a set of directions for building CPU and GPU versions of the code on the HPC clusters. LAMMPS can be built in many different ways. You may need to include additional packages when building the executable for your work. The build procedures below are just samples.

The performance of the LAMMPS executable can be greatly improved by including the USER-OMP and USER-INTEL acceleration packages. The [USER-INTEL](https://lammps.sandia.gov/doc/Build_extras.html#user-intel) package takes advantage of our Intel hardware and software. The acceleration arises from mixed-precision arithmetic and vectorization. If mixed-precision arithmetic is valid for your work then we recommend the mixed-precision version of LAMMPS. If not then follow the directions for the double-precision version. Note that one can do [test runs](https://github.com/PrincetonUniversity/install_lammps/tree/master/07_mixed_versus_double) using both versions to see if the results differ substantially.

IMPORTANT: If you are doing biomolecular simulations involving PPPM and the various bond, angle and dihedral potentials, to use the USER-INTEL package you may need these substitutions for the lines in the build procedures below:

```bash
wget https://github.com/lammps/lammps/archive/patch_4Feb2020.tar.gz
module load intel/18.0/64/18.0.3.222
module load intel-mpi/intel/2018.3/64
```

That is, the patched version of the latest release is needed and the Intel 2018 compiler should be used instead of 2019. For more see [this post](https://lammps.sandia.gov/threads/msg85269.html) on the LAMMPS mailing list.

#### Issue with version 29Oct2020

You may encounter the following error:

```
Fatal Error: File 'mpi.mod' opened at (1) is not a GNU Fortran module file
```

The solution is to explicitly specify the Fortran compiler in the .sh build script:

```
-D CMAKE_Fortran_COMPILER=/opt/intel/compilers_and_libraries_2019.5.281/linux/bin/intel64/ifort \
```

The path above corresponds to the module `intel/19.0/64/19.0.5.281`. Use `module show <module name>` to find the path for a different module.

#### make test

The "make test" command in many of the install scripts is commented out. This is due to way that LAMMPS handles running unit tests ([read more](https://sourceforge.net/p/lammps/mailman/message/37352519/)). In short, multiple tests typically fail when compiler optimizations (e.g., -O2) are turned on. You may consider doing a test install with "-O0" and then if all tests pass do the actual install with something like "-Ofast".


## Obtaining the code and starting the build

The first step is to download the source code and make a build directory (make sure you get the [latest stable release](https://lammps.sandia.gov/download.html)):

```
wget https://github.com/lammps/lammps/archive/stable_29Oct2020.tar.gz
tar zxf stable_29Oct2020.tar.gz
cd lammps-stable_29Oct2020
mkdir build
cd build
```

Note that you may find that some of the tests associated with version 29Oct2020 fail when running `make test`. In this case you should either write to the mailing list or use the previous stable release (wget https://github.com/lammps/lammps/archive/stable_3Mar2020.tar.gz).

The next set of directions vary by cluster. Follow the directions below for the cluster of interest.

## Traverse

See [this page](traverse/scripts.md).

## Stellar

See [this page](stellar-intel/scripts.md).


## TigerGPU

See [this page](tigergpu/scripts.md).

## TigerCPU

See [this page](tigercpu/scripts.md).

## Della-GPU

See [this page](della-gpu/scripts.md).

## Della (CPU)

See [this page](della/scripts.md).

## Adroit

See build scripts [here](adroit/scripts.md).

## Getting Help

If you encounter any difficulties while working with LAMMPS then please send an email to <a href="mailto:cses@princeton.edu">cses@princeton.edu</a> or attend a [help session](https://researchcomputing.princeton.edu/education/help-sessions).
