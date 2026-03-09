#!/bin/bash -x
MKLROOT=$PREFIX $PYTHON setup.py build --force install --old-and-unmanageable
