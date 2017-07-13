#!/bin/bash -v

# guided alignment training

# number of iterations with guided alignment priming
# is specified with "-guided-alignment"
# this has to be a multiple of step size

/opt/nmt/nmt-training/train-model.perl \
   -action train \
   -dir /home/administrator/nmt-training/ja-en-lnu/toy-guided-alignment \
   -train-s /home/administrator/nmt-training/ja-en-lnu/toy-data/train.tok.clean.ja \
   -train-t /home/administrator/nmt-training/ja-en-lnu/toy-data/train.tok.clean.en \
   -lang-s ja \
   -lang-t en \
   -dev-s /home/administrator/nmt-training/ja-en-lnu/toy-data/dev.tok.ja \
   -dev-t /home/administrator/nmt-training/ja-en-lnu/toy-data/dev.tok.en \
   -gpu 0 \
   -guided-alignment 30000 \
   -step-size 10000
