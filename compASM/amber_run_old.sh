##################################################################################################
##                      	CompASM Version 1.0   						##
##												##
##                                   								##
## Run Molecular Minimization/Dynamics Simulation file: 					##
##	-$1 -Sander input values given by CompASM						##
##	-$2 -AMBER location folder path given by CompASM, set on ASMPath.tcl			##
##												##
## User can change this file in order to Run sander in a proper way				##
## i.g.:      $2/sander $1									##
##################################################################################################
arg1=$1
arg2=$2


export AMBERHOME=/opt/programs/amber/9/mpich2-intel-13/
#export AMBERHOME=/opt/programs/amber/9/mpich2-gnu-4.4.5
export PATH=$PATH:$AMBERHOME/exe

#export AMBERHOME=/opt/programs/amber/12/gnu-4.4.5

# OpenMPI GCC 4.4.5
#       export MPI_HOME=/opt/programs/OPENMPI/1.6.3/gnu-4.4.5/
#       export PATH=$PATH:/opt/programs/OPENMPI/1.6.3/gnu-4.4.5/bin/
#       export LD_LIBRARY_PATH=/opt/programs/OPENMPI/1.6.3/gnu-4.4.5/lib/






#export AMBERHOME=/opt/programs/amber/12/mpich2-intel-13
#export PATH=$PATH:$AMBERHOME/bin
#PATH="/usr/local/bin:/usr/bin:/bin"
#PATH="$AMBERHOME/bin:$PATH"

###Intel Compilers
export LD_LIBRARY_PATH=/opt/programs/INTEL/2013/composer_xe_2013.1.117/compiler/lib/intel64

###MPICH2 Intel 2013
#       export MPI_HOME=/opt/programs/MPICH2/1.5/intel-13/
#       export PATH=$PATH:/opt/programs/MPICH2/1.5/intel-13/bin/
#       export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/programs/MPICH2/1.5/intel-13/lib/



#mpirun -np 4 sander.MPI $1

sander $1
