#!/bin/sh

#qsub -l nodes=1:ppn=8 -v iseed="$RANDOM",fmean="150",sigma="20",domain="i27",machin="1do2",ntraj="2" mscale-run-repetitive.sh

#for i in 1  # `seq 1 22`

#       do

#       sbatch --export fmean=150,sigma=20,domain=i27,machin=1do2,ntraj=$i mscale-run-repetitive.slurm

#done

#

rm slurm-*.out

#python benchmark-core-distrib.py

for i in `seq 33 40 `

       do

        sbatch --export ntraj=$i pull-1gfp-rep-nter.slurm

#       sbatch --export ntraj=$i pull-1gfp-cv-nter.slurm 

done
