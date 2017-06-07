#!/bin/bash -v

cd <XXX DIR>
. ./local-settings.sh

# report system status
hostname
nvidia-smi
pwd
echo "gpu: $GPU"

dev=data/dev.bpe.<XXX SRC>
ref=data/dev.tok.<XXX TGT>

# model to evaluate
if [ ! -z "$SPEC_MODEL" ]
then
  MODEL=$SPEC_MODEL
else
  MODEL=`ls -t model/model.iter*npz | head -1`
fi

# decode
$marian/build/amun \
      -d $GPU \
      -n --wipo \
      -s data/train.bpe.<XXX SRC>.json \
      -t data/train.bpe.<XXX TGT>.json \
      -m $MODEL \
      < $dev \
      > $MODEL.bpe

sleep 5
sed -r 's/\@\@ //g' < $MODEL.bpe > $MODEL.out

# get BLEU
BLEU_DETAIL=`$mosesdecoder/scripts/generic/multi-bleu.perl $ref < $MODEL.out`
BLEU=`echo $BLEU_DETAIL | cut -f 3 -d ' ' | cut -f 1 -d ','`
echo `date`" $MODEL: $BLEU_DETAIL" >> model/bleu_scores
echo "BLEU = $BLEU"

# record with most recent iteration (or specified iteration)
echo $BLEU_DETAIL > $MODEL.bleu
