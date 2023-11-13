#!/bin/bash   

# User-defined inputs
PROGRAM_ORDER="./program_order.txt"
LOGFILE=output/build.log

# Constants
PATH_TO_ROOT=..
PATH_TO_MAKE_LIB=${PATH_TO_ROOT}/lib/shmake/make_lib.sh
PATH_TO_MAKE_EXT=${PATH_TO_ROOT}/lib/shmake/make_externals.sh
PATH_TO_LIB=${PATH_TO_ROOT}/lib/shmake/lib.sh
PATH_TO_ALL_LIBRARIES=${PATH_TO_ROOT}/lib/

export PATH_TO_ROOT
export LOGFILE
export PATH_TO_LIB

# remove previous output
rm -rf external
rm -rf output

# create empty output directories
mkdir -p output
mkdir -p output/figures
mkdir -p output/tables

# remove pre-existing log file
rm -f ${LOGFILE}

# make the shell utility library 
${SHELL} ${PATH_TO_MAKE_LIB}

# load the shell utility library
source ${PATH_TO_LIB} && ${SHELL} ${PATH_TO_MAKE_EXT}

# copy it to this module
cp -r ${PATH_TO_ALL_LIBRARIES} ./lib/

# run the programs in the order specified in the program order file
source ${PATH_TO_LIB} && cat ${PROGRAM_ORDER} | run_programs_in_order

# clean up by removing the shell utility library
rm -f ${PATH_TO_LIB}

