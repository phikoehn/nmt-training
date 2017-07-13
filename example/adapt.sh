#!/bin/bash -v

# training a domain-adapted model, given a base model 
# (which is typically trained on more general data)

# -base-model refers to the training directory for the base model
# all other parameters are for the in-doamin data

/opt/nmt/nmt-training/train-model.perl \
   -action adapt \
   -base-model /home/administrator/nmt-training/ja-en-lnu/toy-multiple-gpu \
   -dir        /home/administrator/nmt-training/ja-en-lnu/toy-adapted \
   -train-s /home/administrator/nmt-training/ja-en-lnu/toy-data/train.tok.clean.ja \
   -train-t /home/administrator/nmt-training/ja-en-lnu/toy-data/train.tok.clean.en \
   -lang-s ja \
   -lang-t en \
   -dev-s /home/administrator/nmt-training/ja-en-lnu/toy-data/dev.tok.ja \
   -dev-t /home/administrator/nmt-training/ja-en-lnu/toy-data/dev.tok.en \
   -gpu 0 \
   -step-size 10000
