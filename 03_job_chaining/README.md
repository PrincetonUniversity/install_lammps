# Job Chaining

This page presents two ways to have your job be automatically resubmitted to the cluster after it finishes. This is useful for long jobs that need to run for much longer than the time limit. The first approach uses job dependencies which a feature built into Slurm. The second way uses recursion and while it is more cumbersome it may be more useful in some cases.

To use job chaining your application must have a way of writing a checkpoint file and it must be able to figure out which checkpoint file to read at the start of each job step. If your application doesn't provide these two requirements then one can typically write scripts to deal with it.

## I. Job Dependencies

For the first step, run your job as usual: `sbatch job.slurm`. Make sure it finishes before the time limit and make sure you write a checkpoint file. Then modify the LAMMPS script to read in the checkpoint file at the start of job step, for example:

```
read_restart    restart.equil.*

pair_style      lj/cut 2.5
pair_coeff      1 1 1.0 1.0 2.5

neighbor        0.3 bin
neigh_modify    every 20 delay 0 check no

fix             1 all nve
fix             2 all langevin 1.0 1.0 1.0 48279

timestep        0.005

thermo          5000
run             10000

write_restart   restart.equil.*
```

Also, modify the Slurm script by adding this line: `--dependency=singleton`

```
#!/bin/bash
#SBATCH --job-name=LongLammpsJob
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=00:05:00 # a small value for testing
#SBATCH --dependency=singleton

module purge
module load intel/2022.2.0
module load intel-mpi/intel/2021.7.0

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_della -in in.melt
```

The second and additional steps can then be submitted. Each step will wait for
the one before it since each is waiting for `LongLammpsJob` to finish. The following will produce a total of 5 steps.

```
sbatch job.slurm # step 2
sbatch job.slurm # step 3
sbatch job.slurm # step 4
sbatch job.slurm # step 5
```

Read more about job dependencies on the [Slurm](https://slurm.schedmd.com/sbatch.html) website.

## II. Recursive Calls

The job dependency method above is the recommended way to run long jobs. The method described here is only useful in certain situations.

### The 1st job step

Run the first job step using the Slurm and LAMMPS scripts below:

```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=00:05:00

module purge
module load intel/2022.2.0
module load intel-mpi/intel/2021.7.0

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

srun $HOME/.local/bin/lmp_mpi -in in.melt.first_step
```

```
# this LAMMPS script is used for the first job step

units           lj
atom_style      atomic

lattice         fcc 0.8442
region          box block 0 10 0 10 0 10
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

write_restart   restart.equil.*
```

### 2nd job step and beyond

When the first job step completes it produces a checkpoint file. To make job chaining work, for the second job step and beyond, you add an `sbatch` command at the bottom of your Slurm script which recursively calls the Slurm script itself. In case something goes wrong an external file is used to track the job step and if the job step exceeds a threshold value the process is stopped.

Create a `step.txt` file by entering the following command:

```
echo 0 > step.txt
```

The command above just makes a file with "0" as the contents. This file must be present to use job chaining as it is presented here.

For the second job step and beyond our Slurm script is the same except we add a call to the script itself after the srun command finishes. We also make sure that the step number is less than the maximum step number.

```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --mem-per-cpu=4G

module purge
module load intel/2022.2.0
module load intel-mpi/intel/2021.7.0

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
 
srun $HOME/.local/bin/lmp_mpi -in in.melt.nth_step

if [ ! -f step.txt ]; then
  echo "step.txt must exist to use job chaining. Exiting ..."
  exit
fi

declare -i max_steps=10
declare -i step=$(cat step.txt)
if [ $step -lt $max_steps ]; then
  sbatch job.slurm.nth_step
  echo $((step + 1)) > step.txt
fi
```

The last few lines in the script above check for the existence of `step.txt`. If the file is found then the value stored in it is compared to `max_steps`. If `step` is less than `max_steps` then the job is resubmitted via the `sbatch` command. The value in `step.txt` is then incremented.

Modifications are also needed to the LAMMPS input script. The first line now reads in the checkpoint file. LAMMPS has a mechanism to automatically find the correct file by using the one with the largest step value. Here are the contents of `in.melt.nth_step`:

```
# this script is used for the 2nd step and higher (up to max_steps)

read_restart    restart.equil.*

pair_style	lj/cut 2.5
pair_coeff	1 1 1.0 1.0 2.5

neighbor	0.3 bin
neigh_modify	every 20 delay 0 check no

fix		1 all nve
fix             2 all langevin 1.0 1.0 1.0 48279

timestep        0.005

thermo		5000
run		10000

write_restart   restart.equil.*
```

A full session is below. It assumes that you built a LAMMPS executable called `lmp_mpi` using the `intel` and `intel-mpi` modules and that the executable is in `.local/bin`. If this is not the case then you will need to modify `job.slurm.1st_step` and `job.slurm.nth_step`.

```
ssh <netid>@della.princeton.edu
git clone https://github.com/jdh4/install_lammps.git
cd install_lammps

sbatch job.slurm.1st_step
# wait for the above to finish
sbatch job.slurm.nth_step
```

Here is the output of the above for `max_steps=10`:

```
-rw-r--r--. 1 jdh4 345K Jul  5 11:54 restart.equil.10000
-rw-r--r--. 1 jdh4 2.2K Jul  5 11:54 slurm-24825858.out
-rw-r--r--. 1 jdh4 345K Jul  5 11:55 restart.equil.20000
-rw-r--r--. 1 jdh4 2.3K Jul  5 11:55 slurm-24825859.out
-rw-r--r--. 1 jdh4 345K Jul  5 11:55 restart.equil.30000
-rw-r--r--. 1 jdh4 2.3K Jul  5 11:55 slurm-24825860.out
-rw-r--r--. 1 jdh4 345K Jul  5 11:56 restart.equil.40000
-rw-r--r--. 1 jdh4 2.3K Jul  5 11:56 slurm-24825861.out
-rw-r--r--. 1 jdh4 345K Jul  5 11:56 restart.equil.50000
-rw-r--r--. 1 jdh4 2.3K Jul  5 11:56 slurm-24825862.out
-rw-r--r--. 1 jdh4 345K Jul  5 11:57 restart.equil.60000
-rw-r--r--. 1 jdh4 2.3K Jul  5 11:57 slurm-24825864.out
-rw-r--r--. 1 jdh4 345K Jul  5 11:57 restart.equil.70000
-rw-r--r--. 1 jdh4 2.3K Jul  5 11:57 slurm-24825865.out
-rw-r--r--. 1 jdh4 345K Jul  5 11:58 restart.equil.80000
-rw-r--r--. 1 jdh4 2.3K Jul  5 11:58 slurm-24825866.out
-rw-r--r--. 1 jdh4 345K Jul  5 11:58 restart.equil.90000
-rw-r--r--. 1 jdh4 2.3K Jul  5 11:58 slurm-24825967.out
-rw-r--r--. 1 jdh4 345K Jul  5 11:59 restart.equil.100000
-rw-r--r--. 1 jdh4 2.3K Jul  5 11:59 slurm-24825968.out
-rw-r--r--. 1 jdh4 345K Jul  5 12:00 restart.equil.110000
-rw-r--r--. 1 jdh4 2.3K Jul  5 12:00 slurm-24825969.out
-rw-r--r--. 1 jdh4 345K Jul  5 12:00 restart.equil.120000
-rw-r--r--. 1 jdh4 2.3K Jul  5 12:00 slurm-24825970.out
-rw-r--r--. 1 jdh4 2.4K Jul  5 12:00 log.lammps
-rw-r--r--. 1 jdh4    3 Jul  5 12:00 step.txt
```

The job will run and be automatically re-submitted until `step` equals `max_steps`. Note that you can end the process early by storing a large value in `step.txt` or by deleting the file. If you make a mistake and you need to cancel *all* your pending jobs then run: `scancel --state=PENDING --user=<netid>`

Note that because LAMMPS input scripts support control flow statements like `if-else`, one can combine the two input scripts into one. The same can be done for the Slurm scripts.
