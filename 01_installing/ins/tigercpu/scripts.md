# Tiger

## CPU

[Tiger (CPU)](https://researchcomputing.princeton.edu/systems/tiger) is composed of 320 nodes with 112 CPU-cores per node. Tiger (CPU) should be used for running multi-node parallel jobs. Single-node jobs should be run on Della.

### Mixed-precision version

Run the commands below to build a version of LAMMPS for Tiger (CPU) with [INTEL](../misc/notes.md#INTEL):

```
$ ssh <YourNetID>@tigercpu.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/tigercpu/tigerCpu_user_intel.sh
# use a text editor to inspect tigerCpu_user_intel.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash tigerCpu_user_intel.sh | tee install_lammps.log
```
The executable will be installed into `~/.local/bin` which is included in your `PATH` by default.

Below is a sample Slurm script:

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=4               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu

module purge
module load intel/19.1/64/19.1.1.217
module load intel-mpi/intel/2019.7/64
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_tigerCpu -sf intel -in in.melt
```

View the [in.melt](../misc/in.melt) file. Users will need to find the optimal values for `nodes`, `ntasks` and `cpus-per-task`. This can be done by conducting a [scaling analysis](https://researchcomputing.princeton.edu/support/knowledge-base/scaling-analysis).

### Double-precision version

The code could also be built without [USER-INTEL](../misc/notes.md#user-intel).

## GPU

## Getting Help

If you encounter any difficulties while working with LAMMPS then please send an email to <a href="mailto:cses@princeton.edu">cses@princeton.edu</a> or attend a [help session](https://researchcomputing.princeton.edu/support/help-sessions).
