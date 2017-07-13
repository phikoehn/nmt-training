#!/bin/bash -v

# after training, package up all relevant files for decoding

# optional parameters:
#  -ensemble NUM (default 4): number of models combined
#  -multiple-models: do not average ensemble models, use them in decoding

/opt/nmt/nmt-training/train-model.perl \
      -action get-system \
      -dir /home/sysadmin/nmt-training/$1/v$2
