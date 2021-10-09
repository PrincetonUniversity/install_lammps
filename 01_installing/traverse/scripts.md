# Traverse

This cluster is quite different from the others given its IBM POWER9 CPUs. Traverse is composed of 46 nodes with 32 physical CPU cores per node and 4 NVIDIA V100 GPUs per node. Users should only be using this cluster if their LAMMPS simulations can use GPUs. The USER-INTEL package cannot be used on Traverse because the CPUs are made by IBM and not Intel.

Run these commands to install LAMMPS on Traverse:

```bash
$ ssh <YourNetID>@traverse.princeton.edu
$ cd software  # or another location
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/traverse/traverse.sh
# look at traverse.sh and make modifications if necessary (e.g., add/remove LAMMPS packages)
$ bash traverse.sh | tee install_lammps.log
```

Below is a sample Slurm script to run a simple Lennard-Jones melt:

```bash
#!/bin/bash
#SBATCH --job-name=lj-melt       # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=16              # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --ntasks-per-core=1      # setting to 1 turns off SMT (max value is 4)
#SBATCH --mem=8G                 # total memory per node (4G is default per cpu-core)
#SBATCH --gres=gpu:1             # number of gpus per node
#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=<YourNetID>@princeton.edu

module purge
module load openmpi/gcc/4.1.1/64
module load fftw/gcc/3.3.8
module load cudatoolkit/11.4
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_traverse -sf gpu -in in.melt.gpu
```

Users will need to find the optimal values for `nodes`, `ntasks`, `cpus-per-task`, `ntasks-per-core` and `gres`. Each node of Traverse has 2 CPUs. Each CPU has 16 physical cores. Each physical core has 4 floating point units. A setting of `--ntasks-per-core=4` turns on IBM's simultaneous multithreading (SMT). A setting of `--ntasks-per-core=1` turns it off. Note that the cudatoolkit module does not need to be loaded in the Slurm script since the only CUDA library that the LAMMPS executable depends on is /usr/lib64/libcuda.so, which relates to the driver.

Below is a sample LAMMPS script called `in.melt.gpu`:

```
package         gpu 1

units           lj
atom_style      atomic

lattice         fcc 0.8442
region          box block 0 30 0 30 0 30
create_box      1 box
create_atoms    1 box
mass            1 1.0

velocity        all create 1.0 87287

pair_style      lj/cut/gpu 2.5 # explicit gpu pair style
pair_coeff      1 1 1.0 1.0 2.5

neighbor        0.3 bin
neigh_modify    every 20 delay 0 check no

fix             1 all nve
fix             2 all langevin 1.0 1.0 1.0 48279

timestep        0.005

thermo          5000
run             10000
```

To use 2 GPUs, replace `package gpu 1` with `package gpu 2` and `-sf gpu` with `-sf gpu -pk gpu 2` and `#SBATCH --gres=gpu:1` with `#SBATCH --gres=gpu:2`.
