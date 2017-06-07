#!/bin/bash -v

cd <XXX DIR>

qsub -l 'hostname=c*,gpu=1' \
   -o `pwd`/qsub/validate-alignment.`date +"%Y-%m-%d.%H-%M-%S"`.out \
   -e `pwd`/qsub/validate-alignment.`date +"%Y-%m-%d.%H-%M-%S"`.err \
  ./validate-alignment.sh

