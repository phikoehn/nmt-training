#!/bin/sh

export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/home/shuoyangd/local/lib/cudnn/lib64:$LD_LIBRARY_PATH
export LIBRARY_PATH=/usr/local/cuda/lib64:/home/shuoyangd/local/lib/cudnn/lib64:$LIBRARY_PATH
export CPATH=/usr/local/cuda/include:/home/shuoyangd/local/lib/cudnn/include:$CPATH

# set GPU as specified with <XXX GPU> or dynamically
export GPU=`/home/pkoehn/statmt/bin/free-gpu`
#export GPU=<XXX GPU>

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
export mosesdecoder=/home/pkoehn/moses

# path to subword segmentation scripts: https://github.com/rsennrich/subword-nmt
export subword_nmt=/home/pkoehn/statmt/project/subword-nmt

# path to nematus ( https://www.github.com/rsennrich/nematus )
export nematus=/home/pkoehn/statmt/project/nematus/nematus

# path to guided alignment training version of nematus ( https://github.com/phikoehn/nematus-guided-alignment )
export nematus_guided_alignment=/home/pkoehn/statmt/project/nematus-guided-alignment

# path to fast align
export fast_align=/home/pkoehn/statmt/project/fast_align/build/fast_align

# path to amunmt binary
export amun=/home/pkoehn/statmt/project/amunmt/build/amun

# path to marian binary
export marian=/home/pkoehn/statmt/project/amunmt/build/marian

# execution of validation script
export validate=./validate.sh
#export validate="./validate.sh > validate.stdout 2> validate.stderr"
#export validate="\"qsub -l 'gpu=1,hostname=[bc]*' <XXX DIR>/validate.sh\""

# settings if jobs are submitted on grid engine
export qsub_settings="gpu=1,hostname=c*"
