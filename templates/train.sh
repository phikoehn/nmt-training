#!/bin/bash -v

cd <XXX DIR>
. ./local-settings.sh

# report system status
hostname
nvidia-smi
pwd
echo "gpu: $GPU"

export IPYTHONDIR=<XXX DIR>/ipython
export THEANO_FLAGS=mode=FAST_RUN,floatX=float32,device=gpu$GPU,on_unused_input=warn 
<XXX GUIDED_ALIGNMENT_CMD>
python config.py
