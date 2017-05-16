#!/bin/sh

export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export PATH=/usr/local/cuda-8.0/bin:$PATH

# set GPU as specified with <XXX GPU> or dynamically
#export GPU=`./free-gpu`
export GPU="<XXX GPU>"

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
export mosesdecoder=/opt/nmt/mosesdecoder

# path to subword segmentation scripts: https://github.com/rsennrich/subword-nmt
export subword_nmt=/opt/nmt/subword-nmt

# path to nematus ( https://www.github.com/rsennrich/nematus )
export nematus=/opt/nmt/nematus/nematus

# path to guided alignment training version of nematus ( https://github.com/phikoehn/nematus-guided-alignment )
export nematus_guided_alignment=/opt/nmt/nematus-guided-alignment

# path to fast align
export fast_align=/opt/nmt/fast_align/build/fast_align

# path to amunmt binary
export amun=/opt/nmt/amunmt.v2/build/amun

# path to marian binary
export marian=/opt/nmt/amunmt.v2/build/marian

# execution of validation script
export validate="./validate.sh"
#export validate="qsub -l 'gpu=1,hostname=[bc]*' <XXX DIR>/validate.sh"

# settings if jobs are submitted on grid engine
#export qsub_settings="gpu=1,hostname=c*"
