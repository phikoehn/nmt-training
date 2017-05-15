#!/bin/bash

hostname
nvidia-smi
export device=gpu`/home/pkoehn/statmt/bin/free-gpu`
THEANO_FLAGS=mode=FAST_RUN,device=$device,floatX=float32,optimizer_including=conv_dnn python /home/pkoehn/statmt/project/nmt-training/test-gpu.py 

