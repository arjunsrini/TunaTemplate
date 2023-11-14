#!/bin/bash   

# Project log
PROJECT_NAME="TunaTemplate"
PROJECT_LOGFILE="build.log"

# Exit on non-zero return values (errors)
set -e

# Print project name
echo -e "Making \033[35m${PROJECT_NAME}\033[0m with shell: ${SHELL}"

# Run makeiles of each submodule
rm -f ${PROJECT_LOGFILE}
{
    (cd data && ${SHELL} make.sh)
    (cd analysis && ${SHELL} make.sh)
    (cd paper_slides && ${SHELL} make.sh)
} 2>&1 | tee ${PROJECT_LOGFILE}
