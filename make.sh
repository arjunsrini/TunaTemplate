#!/bin/bash   

# Project log
PROJECT_LOGFILE="build.log"

# Run makeiles of each submodule
rm -f ${PROJECT_LOGFILE}
{
    (cd data && ${SHELL} make.sh)
    (cd analysis && ${SHELL} make.sh)
    (cd paper_slides && ${SHELL} make.sh)
} 2>&1 | tee ${PROJECT_LOGFILE}
