#!/bin/bash -v

cd <XXX DIR>
. ./local-settings.sh

# report system status
hostname
nvidia-smi
pwd
echo "gpu: $GPU"

# kick off training
$marian/build/marian \
        --model model/model.npz \
        --devices $GPU --seed 0 \
        --train-sets data/train.bpe.<XXX SRC> data/train.bpe.<XXX TGT> \
        --vocabs data/train.bpe.<XXX SRC>.json data/train.bpe.<XXX TGT>.json \
        --dynamic-batching -w 3000 \
        --dim-vocabs 50000 50000 \
        --layer-normalization --dropout-rnn 0.2 --dropout-src 0.1 --dropout-trg 0.1 \
        --early-stopping 5 --moving-average \
        --valid-freq <XXX STEP_SIZE> --save-freq <XXX STEP_SIZE> --disp-freq 1000 \
        --valid-sets data/dev.bpe.<XXX SRC> data/dev.bpe.<XXX TGT> \
        --valid-metrics cross-entropy valid-script \
        --valid-script-path $validate \
        --log model/train.log --valid-log model/valid.log
