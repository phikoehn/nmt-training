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
      -n \
      -s data/train.bpe.<XXX SRC>.json \
      -t data/train.bpe.<XXX TGT>.json \
      -m $MODEL \
      --return-soft-alignment \
      < $dev \
      > $MODEL.soft-align

sleep 5
perl -ne '/^(.+) \|\|\| / || die; print $1."\n";' < $MODEL.soft-align > $MODEL.bpe
sed -r 's/\@\@ //g' < $MODEL.bpe > $MODEL.out

# get BLEU
BLEU_DETAIL=`$mosesdecoder/scripts/generic/multi-bleu.perl $ref < $MODEL.out`
BLEU=`echo $BLEU_DETAIL | cut -f 3 -d ' ' | cut -f 1 -d ','`
echo `date`" $MODEL: $BLEU_DETAIL" >> model/bleu_scores
echo "BLEU = $BLEU"

# record with most recent iteration (or specified iteration)
echo $BLEU_DETAIL > $MODEL.bleu

# evaluate alignment
ALIGN=data/train.fast-align
paste $dev $MODEL.bpe | sed -r 's/\t/ \|\|\| /;' | \
  $fast_align/force_align.py $ALIGN.parameter $ALIGN.log $ALIGN-inverse.parameter $ALIGN-inverse.log \
  > $MODEL.fast-align

./evaluate-alignment.perl $dev $MODEL.soft-align $MODEL.fast-align > $MODEL.alignment-score
