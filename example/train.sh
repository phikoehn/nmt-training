#!/bin/bash -v

# most typical invocation of training
# given a tokenized (& lowercased, etc.) corpus and dev set

/opt/nmt/nmt-training/train-model.perl \
   -action train \
   -dir /home/administrator/nmt-training/ja-en-lnu/toy \
   -train-s /home/administrator/nmt-training/ja-en-lnu/toy-data/train.tok.clean.ja \
   -train-t /home/administrator/nmt-training/ja-en-lnu/toy-data/train.tok.clean.en \
   -lang-s ja \
   -lang-t en \
   -dev-s /home/administrator/nmt-training/ja-en-lnu/toy-data/dev.tok.ja \
   -dev-t /home/administrator/nmt-training/ja-en-lnu/toy-data/dev.tok.en \
   -gpu 0 \
   -step-size 10000
