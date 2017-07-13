#!/bin/bash -v

# Just like a regular training run, but using both GPU 0 and GPU 1

/opt/nmt/nmt-training/train-model.perl \
   -action train \
   -dir /home/administrator/nmt-training/ja-en-lnu/toy-multiple-gpu \
   -train-s /home/administrator/nmt-training/ja-en-lnu/toy-data/train.tok.clean.ja \
   -train-t /home/administrator/nmt-training/ja-en-lnu/toy-data/train.tok.clean.en \
   -lang-s ja \
   -lang-t en \
   -dev-s /home/administrator/nmt-training/ja-en-lnu/toy-data/dev.tok.ja \
   -dev-t /home/administrator/nmt-training/ja-en-lnu/toy-data/dev.tok.en \
   -gpu "0 1" \
   -step-size 10000
