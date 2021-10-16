# Stellar

The Intel portion of [Stellar](https://researchcomputing.princeton.edu/systems/stellar) is composed of 296 nodes with 96 CPU-cores per node. Stellar is designed for multinode jobs. If your jobs uses less than 47 cores then it will land in the `serial` QoS which has the lowest priority.

Run these commands to install LAMMPS with the [INTEL-USER](../misc/notes.md#USER-INTEL) package on Stellar:

```
$ ssh <YourNetID>@stellar-intel.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/stellar/stellar_intel_lammps_user_intel.sh
# use a text editor to inspect stellar_intel_lammps_user_intel.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash stellar_intel_lammps_user_intel.sh | tee install_lammps.log
```

The executable will be installed into `~/.local/bin` which is included in your `PATH` by default. See the 01_installing/ins/stellar directory in this repo for alternative builds.

The following Slurm script can be used on stellar-intel with the user-intel version:

```
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=96              # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu

module purge
module load intel/19.1.1.217
module load intel-mpi/intel/2019.7
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_user_intel -sf intel -in in.melt
```

View the [in.melt](../misc/in.melt) file. Users will need to find the optimal values for `nodes`, `ntasks` and `cpus-per-task`. This can be done by conducting a [scaling analysis](https://researchcomputing.princeton.edu/support/knowledge-base/scaling-analysis). All users should follow the [Stellar guidelines](https://researchcomputing.princeton.edu/systems/stellar#guidelines).

## Getting Help

If you encounter any difficulties while working with LAMMPS then please send an email to <a href="mailto:cses@princeton.edu">cses@princeton.edu</a> or attend a [help session](https://researchcomputing.princeton.edu/support/help-sessions).
