# TigerGPU

[TigerGPU](https://researchcomputing.princeton.edu/systems/tiger) is composed of 80 nodes with 28 CPU-cores per node and 4 NVIDIA P100 GPUs per node.

### Mixed-precision version (recommended)

```bash
$ ssh <YourNetID>@tigergpu.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/tigergpu/tigerGpu_user_intel.sh
# use a text editor to inspect tigerGpu_user_intel.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash tigerGpu_user_intel.sh | tee install_lammps.log
```

The LAMMPS build system will add `-qopenmp`, `-restrict` and `-xHost` to the CXX_FLAGS. Note that the build above includes the MOLECULE, RIGID and KSPACE packages. If you do not need these for your simulations then you should remove them from the .sh file after running `wget`.

The following Slurm script can be used to run the job on the TigerGPU cluster:

```bash
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=4               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --gres=gpu:1             # number of gpus per node
#SBATCH --time=00:01:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu

module purge
module load intel/18.0/64/18.0.3.222
module load intel-mpi/intel/2018.3/64
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_tigerGpu -sf gpu -in in.melt
```

The user should vary the various quantities in the Slurm script to find the optimal values.

To use 2 GPUs, replace `package gpu 1` with `package gpu 2` and `-sf gpu` with `-sf gpu -pk gpu 2` and `#SBATCH --gres=gpu:1` with `#SBATCH --gres=gpu:2`.

### Double-precision version

The code could also be built without USER-INTEL.

## Getting Help

If you encounter any difficulties while working with LAMMPS then please send an email to <a href="mailto:cses@princeton.edu">cses@princeton.edu</a> or attend a [help session](https://researchcomputing.princeton.edu/support/help-sessions).
