# Debugging LAMMPS

For a general guide to debugging, see these [slides](https://w3.pppl.gov/~ethier/PICSCIE/DEBUGGING/Parallel_debugging_2019.pdf) by Stephane Ethier of PPPL.

In preparation for debugging, the first step is to compile and link the code with the `-g` debug flag. This causes source-level information to be retained in the resulting executable. Compiler optimizations should not be used or even set explicitly to `O0`. Note that the code will run slower and the executable will be larger.

Here is an example of how to build LAMMPS for debugging:

```
cmake3 -D CMAKE_INSTALL_PREFIX=$HOME/.local -D LAMMPS_MACHINE=della_debug \
-D CMAKE_BUILD_TYPE=Debug -D ENABLE_TESTING=yes -D BUILD_MPI=yes \
-D BUILD_OMP=yes -D CMAKE_C_COMPILER=icc -D CMAKE_CXX_COMPILER=icpc \
-D PKG_USER-OMP=yes ../cmake
```

By specifying `CMAKE_BUILD_TYPE=Debug` the debug flag is automatically added. This can be seen in the output when the `cmake3` command is executed.

The general instructions for using the DDT parallel debugger on the HPC clusters are [here](https://researchcomputing.princeton.edu/faq/debugging-with-ddt-on-the). Below we present a set of instructions that are specific to getting started with debugging LAMMPS.

## Example

Here we will illustrate how to step through the Langevin thermostat code during a simulation of a simple Lennard-Jones melt.

1. Connect to one of the clusters (e.g., della) using SSH with X11 forwarding enabled:

```
ssh -X <NetID>@della.princeton.edu
```  

2. Change directories into the desired working directory

3. Load the needed environment modules:

```
module load intel intel-mpi
```

4. Lauch the DDT parallel debugger: `/usr/licensed/bin/ddt`

If you receive a message like `ddt: cannot connect to X server 172.17.2.7:22.0` then exit the terminal and reconnect to the cluster.

5. After DDT loads, choose Run. Next, input the settings as shown in the figure below:

<p align="center"> 
<img src="ddt_setup.png">
</p>

6. Click the `Submit` button to submit the job to the queue. The debugging session will begin when the job runs. If the cluster is busy then you may have to wait a substantial amount of time.

When the debugger runs it will stop on the first line of the code on process 0. For LAMMPS this is line 37 of main.cpp which is `MPI_Init(&argc, &argv);`.

Next we will set a breakpoint in the Langevin routine (see `/src/fix_langevin.cpp`). We will then run the code and when the breakpoint is reached, execution will be halted. Choose "Pause" from the pop-up window. We can then step through each line and inspect the values of the variables. Click on "Control" in the menu at the top and choose "Add Breakpoint". Edit the window as shown below and then click "Add".

<p align="center">
<img src="ddt_breakpoint.png">
</p>

Run the code by clicking on the green play button. Execution will stop when the breakpoint is reached. Step into each line of the code by clicking on the "Step Into" button or F5. You can examine process 1 by clicking on that process id in the blue horizontal bar below the main menu at the top of the program.

Hitting the play button will resume execution until the breakpoint is encountered in the next time step. End the session by choosing Quit from the File menu.

If you see the message `A debugger disconnected prematurely: the client is shutting down` then your Slurm allocation has expired.

There is much more that can be done with DDT. If you are new to DDT then you will have to spend some time learning how it works. However, once you know how to use it you can find bugs very quickly.

## GDB

To use the command line debugger GDB, for example:

```
gdb --args lmp_serial -sf intel -in in.peptide
```

## Getting Help

If you encounter any difficulties while working with LAMMPS then please send an email to <a href="mailto:cses@princeton.edu">cses@princeton.edu</a> or attend a [help session](https://researchcomputing.princeton.edu/education/help-sessions).
