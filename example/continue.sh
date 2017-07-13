#!/bin/bash -v

# continue an interrupted training run

/opt/nmt/nmt-training/train-model.perl \
     -action continue \
     -dir /home/sysadmin/nmt-training/$1/v$2
