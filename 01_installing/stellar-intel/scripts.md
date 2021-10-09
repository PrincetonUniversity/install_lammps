# Stellar

The Intel portion of Stellar is composed of 296 nodes with 96 CPU-cores per node.

See the stellar-intel directory at the top of this page. Most users should choose the user-intel version as below:

```
$ ssh <YourNetID>@stellar-intel.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/stellar-intel/stellar_intel_lammps_user_intel.sh
# use a text editor to inspect traverse.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash stellar_intel_lammps_user_intel.sh | tee install_lammps.log
```

The executable will be installed into `~/.local/bin` which is included in your `PATH` by default.

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
module load intel/19.1.1.217 intel-mpi/intel/2019.7
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_user_intel -sf intel -in in.melt
```

Users will need to find the optimal values for `nodes`, `ntasks` and `cpus-per-task`. This can be done by conducting a [scaling analysis](https://researchcomputing.princeton.edu/support/knowledge-base/scaling-analysis). All users should follow the [Stellar guidelines](https://researchcomputing.princeton.edu/systems/stellar#guidelines).
