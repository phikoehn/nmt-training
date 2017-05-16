#!/bin/bash -v

# continue an interrupted training run

/opt/nmt/nmt-training/train-model.perl \
     -action continue \
     -dir /home/administrator/nmt-training/ja-en-lnu/toy-multiple-gpu
