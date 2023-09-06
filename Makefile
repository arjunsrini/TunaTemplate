#!/bin/bash   

# The targets are not actual files:
.PHONY: all analysis data paper

all:
	make data
	make analysis
	make paper

data:
	cd data && $(MAKE)

analysis:
	cd analysis && $(MAKE)

paper:
	cd paper_slides && $(MAKE)

