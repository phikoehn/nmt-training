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

# path to fast align
export fast_align=/opt/nmt/fast_align/build

# path to marian 
export marian=-/opt/nmt/marian-refactor-rnn

# execution of validation script
export validate=./fork-validate.sh
#export validate=./qsub-validate.sh

# settings if jobs are submitted on grid engine
#export qsub_settings="gpu=1,hostname=c*"
