#!/bin/bash


#------------------------
# Written by: Sadra Avestan
# Date: February 2019
# This code was to run my simulation on the Comet and Bridges cluster during my Ph.D.
# It runs the CHARMM code for 600 cycles and then syncs the simulation results to the local machine
# and delete everything from the cluster
#---------------------------

#SBATCH --job-name="charmm"

#SBATCH -A cin108

#SBATCH --partition=compute

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=16

#SBATCH -t 48:00:00

#SBATCH --export=ALL

#-------------------------------------------------------------------------

export LD_LIBRARY_PATH=/home/sadra/shared/gcc-5.2.0/lib64:$LD_LIBRARY_PATH

export PATH=/home/sadra/shared/gcc-5.2.0/bin:$PATH

export PATH=/home/sadra/shared/openmpi/bin:$PATH

export MPI_LIB=/home/sadra/shared/openmpi/lib

export MPI_INCLUDE=/home/sadra/shared/openmpi/include

export LD_LIBRARY_PATH=/home/sadra/shared/openmpi/lib:$LD_LIBRARY_PATH

#-------------------------------------------------------------------------

##________________define variables here_______________

ntraj=$ntraj

T=300

force=45

iseed=$RANDOM

nocycle=600

linker=22

ter="cter"

jobname=1gfp-$ter-repetitive-pull-6atpase-s3-l$linker-T$T-f$force

corenum=16

inpname=pulling-go-6atpase-1gfp-$ter-repetitive_force.inp

##___________________________directions__________________________

tmpdir=/scratch/$USER/$SLURM_JOB_ID

jobdir=$jobname-traj$ntraj

inpdir=${SLURM_SUBMIT_DIR}

psfdir=/home/sadra/gfp-26s/psfgen/1gfp

outdir=/oasis/projects/nsf/cin108/sadra/gfp-26s/trajs/1gfp/constant_pull

#jobname=$level-$machin-$domain

CHMEXE=/home/sadra/app/c40b1/exec/gnu_M/charmm.mpi.mscale.tmd.cvel.megatypes # don't change this

##__________________________________________________________________

cd      ${tmpdir}

mkdir   ${jobdir}

cd      ${jobdir}

cp $CHMEXE                      charmm

cp $inpdir/*.inp                .

cp -r $psfdir                   .

##_______________++RUN START AND THEN THE RESTAR FILE++_______________##

mpirun -np $corenum ./charmm iseed=$iseed ntraj=$ntraj linker=$linker T=$T force=$force ter=$ter < dyna_1gfp-$ter-repetitive_force_strt.inp > dyna_repetitive_force_str.out

wait

maxcycle=$nocycle

mode=(pull relax)

for count in `seq 1 $maxcycle`; do

        for imode in ${mode[@]}; do

                mv gfp-repetitive-f$force.res gfp-repetitive-f$force.rea

        mpirun -np $corenum ./charmm ntraj=$ntraj linker=$linker T=$T count=$count imode=$imode force=$force ter=$ter  < $inpname > cyc$count-$imode.out

        wait

        gzip -f  cyc$count-$imode.out

        if [ -e stop.flag ]; then break 2; fi

        if [ $count == 1 ]; then cat $count-confined_list.dat > confined_resid_info.dat

                else grep -v "#" $count-confined_list.dat >> confined_resid_info.dat ; fi

                rm $count-confined_list.dat

    done

done

#### remove the localized charmm and bring back working dir to the storage

rm charmm ## defined localy

rsync -auvz ${tmpdir}/${jobdir} ${outdir}/
