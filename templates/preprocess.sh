#!/bin/bash -v

cd <XXX DIR>
. ./local-settings.sh

# suffix of source language files
SRC=<XXX SRC>

# suffix of target language files
TRG=<XXX TGT>

# number of merge operations. Network vocabulary should be slightly larger (to include characters),
# or smaller if the operations are learned on the joint vocabulary
bpe_operations=49500

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
$mosesdecoder/scripts/training/clean-corpus-n.perl data/train.tok $SRC $TRG data/train.tok.clean 1 80

# train BPE
cat data/train.tok.clean.$SRC data/train.tok.clean.$TRG | $subword_nmt/learn_bpe.py -s $bpe_operations > model/$SRC$TRG.bpe

# apply BPE
$subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/dev.tok.$SRC > data/dev.bpe.$SRC
$subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/dev.tok.$TRG > data/dev.bpe.$TRG
$subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/train.tok.clean.$SRC > data/train.bpe.$SRC
$subword_nmt/apply_bpe.py -c model/$SRC$TRG.bpe < data/train.tok.clean.$TRG > data/train.bpe.$TRG

# build network dictionary
$nematus/../data/build_dictionary.py data/train.bpe.$SRC data/train.bpe.$TRG

<XXX GUIDED_ALIGNMENT_PREP>
