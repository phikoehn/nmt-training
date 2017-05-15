#!/bin/bash -v

cd <XXX DIR>
. ./local-settings.sh

# report system status
hostname
nvidia-smi
pwd
echo "gpu: $GPU"

$subword_nmt/apply_bpe.py -c <XXX DIR>/system/<XXX SRC><XXX TGT>.bpe < <XXX TEST> > <XXX TEST>.bpe

$amun \
    -d $GPU \
    -n --wipo \
    -s data/train.bpe.<XXX SRC>.json \
    -t data/train.bpe.<XXX TGT>.json \
    -m <XXX MODEL> \
    < <XXX TEST>.bpe \
    > <XXX TEST>.<XXX MODEL_TAG>.bpe

sleep 5
sed -r 's/\@\@ //g' < <XXX TEST>.<XXX MODEL_TAG>.bpe > <XXX TEST>.<XXX MODEL_TAG>.tok

