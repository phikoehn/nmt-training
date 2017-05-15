#!/bin/bash

export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/home/pkoehn/statmt/project/cudnn/lib64:$LD_LIBRARY_PATH
export LIBRARY_PATH=/usr/local/cuda/lib64:/home/pkoehn/statmt/project/cudnn/lib64:$LIBRARY_PATH
export CPATH=/usr/local/cuda/include:/home/pkoehn/statmt/project/cudnn/include:$CPATH

hostname
nvidia-smi
export device=gpu`/home/pkoehn/statmt/bin/free-gpu`
THEANO_FLAGS=mode=FAST_RUN,device=$device,floatX=float32,optimizer_including=cudnn python /home/pkoehn/statmt/project/nmt-training/test-gpu.py 

