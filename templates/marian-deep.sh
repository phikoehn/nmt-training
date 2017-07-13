#!/bin/bash -v

cd <XXX DIR>
. ./local-settings.sh

# report system status
hostname
nvidia-smi
pwd
echo "gpu: $GPU"

# set chosen gpus
SRC="<XXX SRC>"
TGT="<XXX TGT>"

# kick off training
$marian --model model/model.npz \
        --devices $GPU --seed 0 \
        --train-sets data/train.bpe.$SRC data/train.bpe.$TGT \
        --vocabs data/train.bpe.$SRC.json data/train.bpe.$TGT.json \
        --dim-vocabs 50000 50000 \
        --dynamic-batching -w 6000 \
        --type s2s \
        --moving-average \
        --best-deep --dec-cell lstm --enc-cell lstm \
        --layer-normalization --dropout-rnn 0.2 --dropout-src 0.1 --dropout-trg 0.1 \
        --early-stopping 5 \
        --valid-freq 10000 --save-freq 10000 --disp-freq 1000 \
        --valid-sets data/dev.bpe.$SRC data/dev.bpe.$TGT \
        --valid-metrics cross-entropy valid-script \
        --valid-script-path $validate \
        --log model/train.log --valid-log model/valid.log

