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

export THEANO_FLAGS="mode=FAST_RUN,floatX=float32,device=gpu$GPU,on_unused_input=warn"
<XXX GUIDED_ALIGNMENT_CMD>

$marian --model model/model.npz \
        --devices $GPU --seed 0 \
        --train-sets data/train.bpe.$SRC data/train.bpe.$TGT \
        --vocabs model/vocab.$SRC.yml model/vocab.$TGT.yml \
        --dim-vocabs 50000 50000 \
        --dynamic-batching -w 3000 \
        --layer-normalization --dropout-rnn 0.2 --dropout-src 0.1 --dropout-trg 0.1 \
        --early-stopping 5 --moving-average \
        --valid-freq <XXX STEP_SIZE> --save-freq <XXX STEP_SIZE> --disp-freq 1000 \
        --valid-sets data/dev.bpe.$SRC data/dev.bpe.$TGT \
        --valid-metrics cross-entropy valid-script \
        --valid-script-path $validate \
        --log model/train.log --valid-log model/valid.log
