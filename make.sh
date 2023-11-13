#!/bin/bash   

# Run makeiles of each submodule
(cd data && ${SHELL} make.sh)
(cd analysis && ${SHELL} make.sh)
(cd paper_slides && ${SHELL} make.sh)

