#!/bin/bash   

# User-defined inputs
PROGRAM_ORDER="./program_order.txt"
LOGFILE=output/build.log

# Constants
PATH_TO_ROOT=..
ENV_DIR="venv"
PATH_TO_MAKE_LIB=${PATH_TO_ROOT}/lib/shmake/make_lib.sh
PATH_TO_MAKE_EXT=${PATH_TO_ROOT}/lib/shmake/make_externals.sh
PATH_TO_LIB=${PATH_TO_ROOT}/lib/shmake/lib.sh
PATH_TO_ALL_LIBRARIES=${PATH_TO_ROOT}/lib/

export PATH_TO_ROOT
export LOGFILE
export PATH_TO_LIB

# Exit on non-zero return values (errors)
set -e

# print shell being used
echo "\n\nMaking \033[35mpaper_slides\033[0m module with shell: ${SHELL}"

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
source ${PATH_TO_LIB}

# link externals
${SHELL} ${PATH_TO_MAKE_EXT}

# copy it to this module
cp -r ${PATH_TO_ALL_LIBRARIES} ./lib/


# For now: manually copy inputs 
rm -rf input
mkdir input
cp ${PATH_TO_ROOT}/data/output/chips_sold.pdf input/chips_sold.pdf


# create the virtual environment if it doesn't exist
# activate the virtual environment
if [ ! -d "$PATH_TO_ROOT/$ENV_DIR" ]; then
    echo "No virtual environment exists here: $PATH_TO_ROOT/$ENV_DIR"
    create_activate_venv
else 
    echo "Virutal environment exists here: $PATH_TO_ROOT/$ENV_DIR"
    activate_venv
fi

# run the programs in the order specified in the program order file
cat ${PROGRAM_ORDER} | run_programs_in_order

# For now: manually move compiled pdf
mv ./code/paper.pdf ./output/paper.pdf

# clean up by removing the shell utility library
rm -f ${PATH_TO_LIB}
