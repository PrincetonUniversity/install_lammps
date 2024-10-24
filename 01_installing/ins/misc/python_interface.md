# LAMMPS with Python Interface

LAMMPS can be built with a Python interface as [described here](https://docs.lammps.org/Python_head.html). Run the commands below (for Della with INTEL package) to build the code in this way:

```
$ ssh <YourNetID>@della.princeton.edu
$ cd software  # or another directory
$ wget https://raw.githubusercontent.com/PrincetonUniversity/install_lammps/master/01_installing/ins/misc/python_interface.md
$ bash lammps_mixed_prec_python_della.sh | tee lammps_mixed_python.log
```

To run a parallel job on Della with the Python interface:

```bash
#!/bin/bash
#SBATCH --job-name=lj-melt                       # create a short name for your job
#SBATCH --nodes=1                                # node count
#SBATCH --ntasks=4                               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1                        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G                         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00                          # total run time limit (HH:MM:SS)
#SBATCH --constraint=cascade                     # run on cascade nodes

module purge
module load intel/2022.2
module load intel-mpi/intel/2021.7.0
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/software/lammps-stable_2Aug2023/build

module load anaconda3/2023.9
conda activate lammps-env

srun python myscript.py
```

Since the command-line switch "-sf intel" cannot be used, one must explicitly turn on the INTEL package and suffix in `in.lj`:

```
units           lj
atom_style      atomic

package         intel 0
suffix          intel

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

timestep        0.005

thermo          5000
run             10000
```

Here are the contents of `myscript.py`:

```python
from mpi4py import MPI
from lammps import lammps
lmp = lammps()
lmp.file("in.lj")
me = MPI.COMM_WORLD.Get_rank()
nprocs = MPI.COMM_WORLD.Get_size()
print("Proc %d out of %d procs has" % (me,nprocs),lmp)
MPI.Finalize()
```

See the [package](https://lammps.sandia.gov/doc/package.html) command for more.

To run a parallel job on Della without the Python interface:

```bash
#!/bin/bash
#SBATCH --job-name=lj-melt                       # create a short name for your job
#SBATCH --nodes=1                                # node count
#SBATCH --ntasks=4                               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1                        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G                         # memory per cpu-core (4G is default)
#SBATCH --time=00:05:00                          # total run time limit (HH:MM:SS)
#SBATCH --constraint=cascade                     # run on cascade nodes

module purge
module load intel/2022.2
module load intel-mpi/intel/2021.7.0
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.local/lib64:$HOME/.conda/envs/lammps-env/lib

srun $HOME/.local/bin/lmp_della -sf intel -in in.melt
```

Here are some timings for the system above with and without the INTEL package on the cascade lake nodes of Della with 4 MPI processes:

| time (s) | INTEL |
|:------:|:------:|
| 120 | with |
| 190 | without |
