#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=10:00:00
#SBATCH --job-name=vis-search
#SBATCH --mail-type=NONE

# Set the amount of time MATLAB is aiming to run for. Speciify as ??:??:??
matlabTimeLim="07:00:00"


# INPUT
# $1 directory. All relevant MATLAB scripts should be in the folder 
#    directory/scripts or a subfolder of this directory. Temp folders will be 
#    created here.
# $2 file name of the job to run
# $3 Are we starting a new fit or resuming and old one ("0" or "1")

umask 077 

jobDirectory="$1"
filename="$2"
resuming="$3"


# Need to provide matlab input as a string
in1="'$jobDirectory'"
in2="'$filename'"
in3="'$resuming'"
timelim="'$matlabTimeLim'"

module load matlab/R2018b
matlab -nodisplay -nosplash -r "mT_runOnCluster($in1, $in2, $in3, $timelim)"



