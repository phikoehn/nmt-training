#!/bin/bash -v

cd <XXX DIR>
. ./local-settings.sh
cd data

paste train.bpe.<XXX SRC> train.bpe.<XXX TGT> | sed -r 's/\t/ \|\|\| /;' > train.prepared

$fast_align/fast_align -d -o -v -r \
  -i train.prepared \
  -p train.fast-align-inverse.parameter \
  >  train.fast-align-inverse \
  2> train.fast-align-inverse.log

$fast_align/fast_align -d -o -v \
  -i train.prepared \
  -p train.fast-align.parameter \
  >  train.fast-align \
  2> train.fast-align.log

$mosesdecoder/scripts/ems/support/symmetrize-fast-align.perl \
  train.fast-align \
  train.fast-align-inverse \
  train.bpe.<XXX SRC> \
  train.bpe.<XXX TGT> \
  train.aligned \
  grow-diag-final-and \
  $mosesdecoder/bin/symal
