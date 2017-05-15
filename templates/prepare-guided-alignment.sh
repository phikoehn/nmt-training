#!/bin/bash -v

cd <XXX DIR>
. ./local-settings.sh
cd data

paste train.tok.clean.<XXX SRC> train.tok.clean.<XXX TGT> | sed -r 's/\t/ \|\|\| /;' > train.prepared

$fast_align -d -o -v -r \
  -i train.prepared \
  -p train.fast-align-inverse.parameter \
  >  train.fast-align-inverse \
  2> train.fast-align-inverse.log

$fast_align -d -o -v \
  -i train.prepared \
  -p train.fast-align.parameter \
  >  train.fast-align \
  2> train.fast-align.log

$mosesdecoder/scripts/ems/support/symmetrize-fast-align.perl \
  train.fast-align \
  train.fast-align-inverse \
  train.tok.clean.<XXX SRC> \
  train.tok.clean.<XXX TGT> \
  train.aligned \
  grow-diag-final-and \
  $mosesdecoder/bin/symal

$nematus_guided_alignment/compile-alignment.py \
  --source    train.bpe.<XXX SRC> \
  --target    train.bpe.<XXX TGT> \
  --alignment train.aligned.grow-diag-final-and \
  --output    train.aligned.grow-diag-final-and.npy

