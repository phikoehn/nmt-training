#!/bin/bash -v

cd <XXX DIR>

qsub -l 'hostname=c*,gpu=1' \
   -o `pwd`/qsub/soft-alignment.`date +"%Y-%m-%d.%H-%M-%S"`.out \
   -e `pwd`/qsub/soft-alignment.`date +"%Y-%m-%d.%H-%M-%S"`.err \
  ./validate-gpu.sh

