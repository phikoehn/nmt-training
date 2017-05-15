import numpy
import os
import sys

sys.path.append(os.environ['nematus_guided_alignment'])

VOCAB_SIZE = 50000
SRC = "<XXX SRC>"
TGT = "<XXX TGT>"

from nmt import train

if __name__ == '__main__':
    validerr = train(saveto='model/model.npz',
                    reload_=True,
                    dim_word=500,
                    dim=1024,
                    n_words=VOCAB_SIZE,
                    n_words_src=VOCAB_SIZE,
                    decay_c=0.,
                    clip_c=1.,
                    lrate=0.0001,
                    optimizer='adadelta',
                    maxlen=50,
                    batch_size=80,
                    shuffle_each_epoch=False, ### Add by pengyu
                    sort_by_length=False,     ### Add by pengyu
                    finish_after=<XXX GUIDED_ALIGNMENT>,       ### Only prime
                    valid_batch_size=80,
                    datasets=['data/train.bpe.' + SRC, 'data/train.bpe.' + TGT, 'data/train.aligned.grow-diag-final-and.npy'],
                    valid_datasets=['data/dev.bpe.' + SRC, 'data/dev.bpe.' + TGT],
                    dictionaries=['data/train.bpe.' + SRC + '.json','data/train.bpe.' + TGT + '.json'],
                    validFreq=<XXX STEP_SIZE>,
                    dispFreq=1000,
                    saveFreq=<XXX STEP_SIZE>,
                    sampleFreq=<XXX STEP_SIZE>,
                    use_dropout=False,
                    dropout_embedding=0.2, # dropout for input embeddings (0: no dropout)
                    dropout_hidden=0.2, # dropout for hidden layers (0: no dropout)
                    dropout_source=0.1, # dropout source words (0: no dropout)
                    dropout_target=0.1, # dropout target words (0: no dropout)
                    overwrite=False,
                    external_validation_script=os.environ['validate'])
    print validerr
