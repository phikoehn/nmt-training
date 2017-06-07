#!/bin/bash -v

cd <XXX DIR>

qsub -l 'hostname=c*,gpu=1' \
   -o `pwd`/qsub/marian-guided-alignment.`date +"%Y-%m-%d.%H-%M-%S"`.out \
   -e `pwd`/qsub/marian-guided-alignment.`date +"%Y-%m-%d.%H-%M-%S"`.err \
  ./marian-guided-alignment.sh

