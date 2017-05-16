#!/bin/bash -v

cd <XXX DIR>
. ./local-settings.sh

# report system status
hostname
nvidia-smi
pwd
echo "gpu: $GPU"

export IPYTHONDIR=<XXX DIR>/ipython
SINGLE_GPU=`echo $GPU | awk '{print $1;}'`
export THEANO_FLAGS=mode=FAST_RUN,floatX=float32,device=gpu$SINGLE_GPU,on_unused_input=warn 
<XXX GUIDED_ALIGNMENT_CMD>
python config.py
