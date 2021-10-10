# Notes

## USER-INTEL

The performance of the LAMMPS executable can be greatly improved by including the USER-INTEL/INTEL package. The [USER-INTEL/INTEL](https://docs.lammps.org/Build_extras.html#intel) package takes advantage of our Intel hardware and software. The acceleration arises from mixed-precision arithmetic and vectorization. If mixed-precision arithmetic is valid for your work then we recommend the mixed-precision version of LAMMPS. If not then build a double-precision version. Note that one can do [test runs](https://github.com/PrincetonUniversity/install_lammps/tree/master/07_mixed_versus_double) using both versions to see if the results differ substantially.

## Unit Testing

The "make test" command in many of the install scripts is omitted. This is due to way that LAMMPS handles running unit tests ([read more](https://sourceforge.net/p/lammps/mailman/message/37352519/)). In short, multiple tests typically fail when compiler optimizations (e.g., -O2) are turned on. You may consider doing a test install with "-O0" and then if all the tests pass do the production install with something like "-Ofast".

## Issue with version 29Oct2020

You may encounter the following error when building the code:

```
Fatal Error: File 'mpi.mod' opened at (1) is not a GNU Fortran module file
```

The solution is to explicitly specify the Fortran compiler in the .sh build script:

```
-D CMAKE_Fortran_COMPILER=/opt/intel/compilers_and_libraries_2019.5.281/linux/bin/intel64/ifort \
```

The path above corresponds to the module `intel/19.0/64/19.0.5.281`. Use `module show <module name>` to find the path for a different module.

## Patch releases

To install a patch release modify the install script as follows, for example:

```
VERSION=4Feb2020
wget https://github.com/lammps/lammps/archive/patch_${VERSION}.tar.gz
tar zxf patch_${VERSION}.tar.gz
cd lammps-patch_${VERSION}
mkdir build && cd build
```

If you have encountering errors when doing biomolecular simulations then see [this post](https://lammps.sandia.gov/threads/msg85269.html) on the LAMMPS mailing list.
