#!/bin/bash -x

# make sure that compiler has been sourced, if necessary

MKLROOT=$CONDA_PREFIX $PYTHON -m pip install --no-build-isolation --no-deps .
