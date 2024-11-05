#!/bin/bash

#---------------------------
# Written by: Sadra Avestan
# Date: February 2019
#----------------------------

#SBATCH -A mc5612p

#SBATCH -N 1 --tasks-per-node=14

#SBATCH -t 48:0:00

#SBATCH -p GPU-shared

#SBATCH --gres=gpu:k80:2

#SBATCH --job-name="clpp"

module load namd/2.13_gpu #   <1==========<< Bridges NAMD GPU VERSION 

#====================================

# external arguments

#====================================

ntraj=$ntraj

symtype=clpp_close

#====================================

# Define executables and directories

#====================================

INPDIR=$SLURM_SUBMIT_DIR

#OUTDIR=$SLURM_SUBMIT_DIR/outputs

OUTDIR=/pylon5/mc5612p/sadra

TRAJDIR=$OUTDIR/$symtype

TMPDIR=$LOCAL

WORKDIR=$symtype-traj$ntraj

#==================================

# Make/copy necessary files/folders

#==================================

if [[ ! -e $TRAJDIR ]]; then

    mkdir -p  $TRAJDIR

fi

mkdir -p  $TMPDIR/$WORKDIR

cd        $INPDIR

cp step3*           $TMPDIR/$WORKDIR

cp step4*           $TMPDIR/$WORKDIR

cp step5*           $TMPDIR/$WORKDIR

cp -r restraints    $TMPDIR/$WORKDIR

cp -r toppar        $TMPDIR/$WORKDIR

cd                   $TMPDIR/$WORKDIR

cnt=47

cnatmax=50

if [ $cnt -eq 1 ]; then

## RUN THE INITIAL-EQUILIB --> AUTOMATIC DIFFERENT SEED (TIME DEPENDENT)

sleep $(($ntraj * 2)) # TO RUN AT DIFFERENT TIME WHILE RUNNING MORE THAN 1 TRAJS IN A LOOP

    $BINDIR/namd2 +p14 +idlepoll step4_equilibration.inp > step4_equilibration.out

fi

## RUNNING THE PRODUCTION STEPS --> EACH CYCLE IS 1 NANOSECOND

### COPY FILES FROM THE RESULTS OF THE LAST STEP OF PREVIOUS RUN

if [ $cnt -ne 1 ]; then

    RC=1

    n=0

    while [[ $RC -ne 0 && $n -lt 20 ]]; do

        prefix=$(($cnt - 1))

        rsync -aP $TRAJDIR/$WORKDIR/step5_${prefix}.coor $TMPDIR/$WORKDIR

        rsync -aP $TRAJDIR/$WORKDIR/step5_${prefix}.vel $TMPDIR/$WORKDIR

        rsync -aP $TRAJDIR/$WORKDIR/step5_${prefix}.xsc $TMPDIR/$WORKDIR

        RC=$?

        let n=n+1

        sleep 10

    done

fi

while [ $cnt -le $cnatmax ]

    do

    # create appropriate input file using step5_production.inp as template

    if [ $cnt -le 1 ]; then

        outputname="step5_${cnt}"

        # change only the output name

        sed "s/step5_production/${outputname}/" step5_production.inp > step5_run.inp

    else

        cntprev=$(( $cnt -1 ))

        inputname="step5_${cntprev}"

        outputname="step5_${cnt}"

        # change input and output names from template file

    #   sed "s/step4_equilibration/${inputname}/" step5_production.inp | \ 

        #       sed "s/step5_production/${outputname}/" > step5_run.inp 

    ## didn't work in .sh fix it later

        sed -e "s/step4_equilibration/${inputname}/g" -e "s/step5_production/${outputname}/g"  step5_production.inp > step5_run.inp

    fi

    # run the simulation for 1 nanosecond/cnt

    $BINDIR/namd2 +p14 +idlepoll step5_run.inp > ${outputname}.out

    cnt=$(( $cnt + 1 ))

done

#rsync -auvzP $TMPDIR/$WORKDIR $TRAJDIR

## This loop  will loop at most 20 times to transfer files and stop if it is successful

RC=1

n=0

while [[ $RC -ne 0 && $n -lt 20 ]]; do

    rsync -aP $TMPDIR/$WORKDIR $TRAJDIR

    RC=$?

    let n=n+1

    sleep 10

done
